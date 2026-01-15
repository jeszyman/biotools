#!/bin/bash
set -e

echo "==> Validating schema structure..."
python scripts/validate_data_schema.py --schema examples/example-metadata-schema.yaml

echo "==> Building Excel from TSVs..."
python scripts/build_excel_from_tsv.py \
  --schema examples/example-metadata-schema.yaml \
  --tsv-dir examples \
  --output examples/example-metadata.xlsx

echo "==> Validating data against schema..."
python scripts/input_data_validator.py \
  --schema examples/example-metadata-schema.yaml \
  --xlsx examples/example-metadata.xlsx \
  --report examples/validation-report.txt

echo "==> Validation complete!"
echo ""
cat examples/validation-report.txt
