# Bioinformatics metadata

#!/usr/bin/env python3
"""
Validate a Frictionless schema YAML file structure only (no data validation).
CLI:
  --schema  Path to Frictionless Package/descriptor (e.g., data_model.yaml)
  --cwd     Optional working directory (chdir before running)
Exit: 0 if valid, 1 otherwise.
"""
import os
import sys
import argparse
from frictionless import Package, FrictionlessException


def parse_args():
    p = argparse.ArgumentParser(
        description="Validate Frictionless schema YAML structure only."
    )
    p.add_argument(
        "--schema",
        required=True,
        help="Path to Package/descriptor YAML (e.g., data_model.yaml)",
    )
    p.add_argument(
        "--cwd", default=None, help="Optional working directory (chdir before running)"
    )
    return p.parse_args()


def validate_schema_file(path: str):
    """Validate Frictionless schema/package structure only (no data validation)."""
    errors = []
    resource_reports = []

    # Try to load the package
    try:
        pkg = Package(path)  # validate package metadata (no data read)
    except FrictionlessException as e:
        errors.append(("package-error", e.error.note))
        for r in e.reasons:
            errors.append((r.type, r.note))
        return resource_reports, errors

    # Validate each resource's schema
    for res in pkg.resources:
        try:
            res.schema.to_descriptor()  # validate schema only
            resource_reports.append((res.name, "OK"))
        except FrictionlessException as e:
            errs = [(f"{res.name}: {e.error.type}", e.error.note)]
            errs.extend([(f"{res.name}: {r.type}", r.note) for r in e.reasons])
            errors.extend(errs)
            resource_reports.append((res.name, "ERROR"))
        except Exception as e:
            errors.append((f"{res.name}: schema-error", str(e)))
            resource_reports.append((res.name, "ERROR"))

    return resource_reports, errors


def render_report(path, resource_reports, errors):
    """Render validation report."""
    print(f"Schema validation report for: {path}")
    print()

    if resource_reports:
        print(f"Resources found: {len(resource_reports)}")
        for name, status in resource_reports:
            status_symbol = "✓" if status == "OK" else "✗"
            print(f"  {status_symbol} {name}: {status}")
        print()

    if not errors:
        print("Result: ✓ All schemas are valid")
        return True
    else:
        print("Schema errors found:")
        for error_type, note in errors:
            print(f"  • {error_type}: {note}")
        print()
        print("Result: ✗ Schema validation failed")
        return False


def main():
    args = parse_args()

    if args.cwd:
        os.chdir(args.cwd)

    try:
        resource_reports, errors = validate_schema_file(args.schema)
        is_valid = render_report(args.schema, resource_reports, errors)
        return 0 if is_valid else 1
    except Exception as e:
        print(f"Error validating schema file '{args.schema}': {e}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
