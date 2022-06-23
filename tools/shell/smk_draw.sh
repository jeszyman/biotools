# Check for parameters and return usage
if [ "$#" -ne 3 ];
then
    printf "\n usage: smk_dry_run.sh config_file smk_file pdf_loc
    \n Draws the rulegraph for a snakemake file at pdf_loc
    \n "
else
    # Necessary to run conda snakemake command in shell script
    eval "$(command conda 'shell.bash' 'hook' 2> /dev/null)"
    #
    conda activate snakemake
    #
    snakemake \
        --configfile $1 \
        --cores 1 \
        --rulegraph \
        --snakefile $2 | dot -Tpdf > $3
fi
