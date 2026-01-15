# - Data model validator

#!/usr/bin/env python3
# ./scripts/input_data_validator.py
"""
Validate ALL Excel sheets corresponding to resources in a Frictionless package.
Strict header check: every schema-declared field must be present in the sheet header.
Only schema-declared fields are validated (extra columns ignored).
Includes foreign key validation across resources.

Exit 0 iff every resource validates; otherwise 1.

CLI:
  --schema   Path to Frictionless Package/descriptor (e.g., data_model.yaml)
  --xlsx     Path to the Excel file
  --report   Path to write a compact, aggregated report (text)
  --cwd      Optional working directory (chdir before running)
"""
import os
import sys
import argparse
from collections import defaultdict, Counter
from typing import Dict, List, Tuple

from frictionless import Package, Resource, formats, FrictionlessException


# -------------------- arg parsing --------------------
def parse_args():
    p = argparse.ArgumentParser(
        description="Validate Excel vs schema for ALL resources (schema fields only, strict header)."
    )
    p.add_argument(
        "--schema",
        required=True,
        help="Path to Package/descriptor YAML (e.g., data_model.yaml)",
    )
    p.add_argument("--xlsx", required=True, help="Path to Excel file")
    p.add_argument(
        "--report", required=True, help="Where to write compact validation report (txt)"
    )
    p.add_argument(
        "--cwd", default=None, help="Optional working directory (chdir before running)"
    )
    return p.parse_args()


# -------------------- header checker --------------------
class HeaderError(Exception):
    """Raised when schema-declared fields are missing from the sheet header."""

    def __init__(self, missing_fields):
        self.missing_fields = list(missing_fields)
        msg = "Missing schema fields in sheet header: " + ", ".join(self.missing_fields)
        super().__init__(msg)


class HeaderReport:
    """Adapter so header failures render via the same code path as frictionless reports."""

    def __init__(self, missing_fields):
        self.valid = False
        self._missing_fields = list(missing_fields)

    def flatten(self, fields):
        # expected fields: ["rowNumber","fieldName","code","message"]
        out = []
        for f in self._missing_fields:
            out.append(
                (None, f, "missing-field", f"Column '{f}' not found in sheet header")
            )
        return out


# -------------------- utils --------------------
def is_blank_value(value):
    if value is None:
        return True
    if isinstance(value, str):
        return value.strip() == ""
    return False if isinstance(value, (int, float)) else (str(value).strip() == "")


def is_row_blank(row_dict, threshold=1):
    return sum(1 for v in row_dict.values() if not is_blank_value(v)) < threshold


# -------------------- core validation --------------------
def validate_one_table(xlsx_path: str, sheet: str, pkg_path: str):
    """
    Validate a single sheet by projecting to schema fields only with STRICT header check.
    Returns a report-like object with .valid and .flatten(...).
    """
    pkg = Package(pkg_path)
    res = pkg.get_resource(sheet)  # resource name == sheet name
    schema = res.schema
    expected = [f.name for f in schema.fields]

    ctrl = formats.ExcelControl(sheet=sheet)
    projected_rows = []
    blank_rows_skipped = 0

    try:
        with Resource(path=xlsx_path, control=ctrl) as src:
            header_labels = list(src.header.to_list()) if src.header else []
            missing_from_sheet = [f for f in expected if f not in header_labels]
            if missing_from_sheet:
                raise HeaderError(missing_from_sheet)

            for row in src.read_rows():
                d = row.to_dict() if hasattr(row, "to_dict") else dict(row)
                proj = {k: d.get(k) for k in expected}
                if is_row_blank(proj, threshold=1):
                    blank_rows_skipped += 1
                    continue
                projected_rows.append(proj)
    except FrictionlessException as e:
        # Treat missing sheet / IO / parse failures as header-level issues
        return HeaderReport([f"<sheet:{sheet}> {e.error.note or 'sheet error'}"])
    except HeaderError as e:
        return HeaderReport(e.missing_fields)

    # Validate only schema fields
    return Resource(data=projected_rows, schema=schema).validate()


def flatten_issues(report):
    return list(report.flatten(["rowNumber", "fieldName", "code", "message"]))


def render_table_block(name: str, report, max_rows=20) -> Tuple[str, bool, int, int]:
    """Return (block_text, valid, n_header, n_rows_with_issues)."""
    lines = []
    lines.append(f"[{name}] valid: {report.valid}\n")

    issues = flatten_issues(report)

    # header issues
    header_issues = {}
    for row, field, code, msg in issues:
        if row is None:
            header_issues[field or ""] = (msg or "").strip()
    if header_issues:
        lines.append("  Header problems:")
        for f, m in header_issues.items():
            lines.append(f"    - {f}: {m}")
        lines.append("")

    # data issues grouped by row
    by_row = defaultdict(list)
    for row, field, code, msg in issues:
        if row is None:
            continue
        by_row[row].append((field or "", code or "error", (msg or "").strip()))

    # code summary
    code_counts = Counter(code for rows in by_row.values() for _, code, _ in rows)
    if code_counts:
        lines.append("  Error code summary:")
        for c, n in code_counts.most_common():
            lines.append(f"    - {c}: {n}")
        lines.append("")

    # sample rows
    n_show = min(max_rows, len(by_row))
    lines.append(f"  First {n_show} problematic rows (of {len(by_row)}):")
    for rownum in sorted(by_row)[:n_show]:
        seen = set()
        compact = []
        for field, code, msg in by_row[rownum]:
            key = (field, code, msg[:120])
            if key in seen:
                continue
            seen.add(key)
            if len(msg) > 140:
                msg = msg[:137] + "..."
            compact.append((field, code, msg))
        lines.append(f"    - row {rownum}:")
        for field, code, msg in compact:
            label = field if field else "<row>"
            lines.append(f"      {label}: [{code}] {msg}")
    lines.append("")

    return "\n".join(lines), bool(report.valid), len(header_issues), len(by_row)


# -------------------- foreign key validation --------------------
def validate_foreign_keys(xlsx_path: str, schema_path: str):
    """
    Validate foreign key constraints across all resources.
    Returns list of FK violation issues.
    """
    fk_issues = []
    try:
        # Create package with paths pointing to actual xlsx
        pkg = Package(schema_path)
        for res in pkg.resources:
            res.path = xlsx_path
            res.control = {"type": "excel", "sheet": res.name}

        # Validate entire package (includes FK checks)
        pkg_report = pkg.validate()

        if not pkg_report.valid:
            # Extract FK-specific errors
            for task in pkg_report.tasks:
                if hasattr(task, "errors"):
                    for error in task.errors:
                        # Foreign key errors typically have 'foreign' or 'key' in type
                        error_type = getattr(error, "type", "")
                        if (
                            "foreign" in error_type.lower()
                            or "key" in error_type.lower()
                        ):
                            fk_issues.append(
                                {
                                    "resource": (
                                        task.resource.name
                                        if hasattr(task, "resource")
                                        else "<unknown>"
                                    ),
                                    "row": getattr(error, "rowNumber", None),
                                    "field": getattr(error, "fieldName", None),
                                    "type": error_type,
                                    "message": getattr(error, "message", str(error)),
                                }
                            )
    except Exception as e:
        fk_issues.append(
            {
                "resource": "<package>",
                "row": None,
                "field": None,
                "type": "foreign-key-validation-error",
                "message": str(e),
            }
        )

    return fk_issues


# -------------------- main --------------------
def main():
    args = parse_args()
    if args.cwd:
        os.chdir(args.cwd)

    pkg = Package(args.schema)
    resource_names = [r.name for r in pkg.resources]

    blocks: List[str] = []
    all_valid = True
    total_header_issues = 0
    total_rows_with_issues = 0
    total_data_issues = 0

    # Validate each resource individually
    for name in resource_names:
        report = validate_one_table(args.xlsx, name, args.schema)
        block, ok, n_hdr, n_rows = render_table_block(name, report)
        blocks.append(block)
        all_valid = all_valid and ok
        total_header_issues += n_hdr
        total_rows_with_issues += n_rows

        # count total data issues from the already-flattened view
        issues = flatten_issues(report)
        data_issues = [t for t in issues if t[0] is not None]
        total_data_issues += len(data_issues)

    # Validate foreign keys across resources
    fk_issues = validate_foreign_keys(args.xlsx, args.schema)

    if fk_issues:
        fk_lines = [
            "=== Foreign Key Violations ===",
            f"Total FK issues: {len(fk_issues)}",
            "",
        ]
        for issue in fk_issues[:20]:  # Show first 20
            row_info = f"row {issue['row']}" if issue["row"] else "header"
            field_info = f"[{issue['field']}]" if issue["field"] else ""
            fk_lines.append(
                f"  {issue['resource']} {row_info} {field_info}: {issue['message']}"
            )
        if len(fk_issues) > 20:
            fk_lines.append(f"  ... and {len(fk_issues) - 20} more")
        fk_lines.append("")
        blocks.append("\n".join(fk_lines))
        all_valid = False

    total_fk_issues = len(fk_issues)

    summary = [
        "=== Validation Summary (all tables) ===",
        f"Resources checked: {len(resource_names)}",
        f"All valid: {all_valid}",
        f"Header issues: {total_header_issues}",
        f"Rows with issues: {total_rows_with_issues}",
        f"Total data issues: {total_data_issues}",
        f"Foreign key issues: {total_fk_issues}",
        "",
        f"[input-data-validator] wrote report -> {args.report}",
    ]

    os.makedirs(os.path.dirname(args.report), exist_ok=True)
    with open(args.report, "w", encoding="utf-8") as fh:
        fh.write("\n".join(blocks + summary))

    print(summary[-1])
    return 0 if all_valid else 1


if __name__ == "__main__":
    sys.exit(main())
