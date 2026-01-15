#!/usr/bin/env python3
"""
Build Excel workbook from TSV files based on Frictionless schema.

For each resource in the schema, reads the corresponding TSV file
and creates a sheet in the Excel workbook.

CLI:
  --schema    Path to Frictionless schema YAML
  --tsv-dir   Directory containing TSV files (named {resource}.tsv)
  --output    Path to write Excel file
  --cwd       Optional working directory (chdir before running)

Exit: 0 if successful, 1 otherwise.
"""
import os
import sys
import argparse
from pathlib import Path

import pandas as pd
from frictionless import Package


def parse_args():
    p = argparse.ArgumentParser(
        description="Build Excel workbook from TSV files based on schema."
    )
    p.add_argument("--schema", required=True, help="Path to Frictionless schema YAML")
    p.add_argument("--tsv-dir", required=True, help="Directory containing TSV files")
    p.add_argument("--output", required=True, help="Output Excel file path")
    p.add_argument("--cwd", default=None, help="Optional working directory")
    return p.parse_args()


def build_excel_from_tsvs(schema_path: str, tsv_dir: str, output_path: str):
    """
    Read schema, load TSV files, create Excel workbook.

    Args:
        schema_path: Path to Frictionless schema YAML
        tsv_dir: Directory containing TSV files named {resource}.tsv
        output_path: Where to write the Excel file

    Returns:
        Dict with resource names and row counts
    """
    # Load schema to get resource names
    pkg = Package(schema_path)
    resource_names = [r.name for r in pkg.resources]

    tsv_dir_path = Path(tsv_dir)
    output_dir = Path(output_path).parent

    # Ensure output directory exists
    output_dir.mkdir(parents=True, exist_ok=True)

    # Track results
    results = {}
    missing = []

    # Create Excel writer
    with pd.ExcelWriter(output_path, engine="openpyxl") as writer:
        for resource_name in resource_names:
            tsv_path = tsv_dir_path / f"{resource_name}.tsv"

            if not tsv_path.exists():
                missing.append(resource_name)
                print(
                    f"Warning: TSV file not found for resource '{resource_name}': {tsv_path}"
                )
                continue

            # Read TSV
            # keep_default_na=False prevents pandas from converting strings like "NA" to NaN
            df = pd.read_csv(tsv_path, sep="\t", keep_default_na=False)

            # Replace empty strings with None for cleaner Excel representation
            df = df.replace("", None)

            # Write to Excel sheet
            df.to_excel(writer, sheet_name=resource_name, index=False)

            results[resource_name] = len(df)
            print(f"✓ {resource_name}: {len(df)} rows")

    if missing:
        print(f"\nWarning: {len(missing)} resource(s) had no TSV file:")
        for name in missing:
            print(f"  - {name}")

    return results, missing


def main():
    args = parse_args()

    if args.cwd:
        os.chdir(args.cwd)

    try:
        results, missing = build_excel_from_tsvs(args.schema, args.tsv_dir, args.output)

        total_rows = sum(results.values())
        print(f"\nCreated {args.output}")
        print(f"Total resources: {len(results)}")
        print(f"Total rows: {total_rows}")

        # Exit with error if any TSVs were missing
        if missing:
            print(f"\nError: {len(missing)} resource(s) missing TSV files")
            return 1

        return 0

    except Exception as e:
        print(f"Error building Excel from TSVs: {e}", file=sys.stderr)
        import traceback

        traceback.print_exc()
        return 1


if __name__ == "__main__":
    sys.exit(main())
