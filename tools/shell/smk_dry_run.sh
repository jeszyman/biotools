# Check for parameters and return usage
if [ "$#" -ne 2 ];
then
    printf "\n usage: smk_dry_run.sh <SMK CONFIG YAML> <SMK FILE>
    \n Script for snakemake dry run.
    \n Will not test singularity container is working
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
        --dry-run \
        --forceall \
        --printshellcmds \
        --use-singularity \
        --snakefile $2
fi
