
# - [[file:./workflow/scripts/make_bwa_index_.sh][Base script]]

mkdir -p $1
bwa index -p $2 -a bwtsw $3
# Snakemake variables
# Function
# Run command
