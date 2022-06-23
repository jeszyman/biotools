# Check for parameters and return usage
if [ "$#" -ne 2 ];
then
    printf "\n usage: smk_forced_run.sh config_file smk_file
    \n Script to complete forced run of snakefile.
    \n Assumes
    - Singularity container specified in config
    - a mount point at /mnt
    \n "
else
    # Necessary to run conda snakemake command in shell script
    eval "$(command conda 'shell.bash' 'hook' 2> /dev/null)"
    #
    conda activate snakemake
    #
    snakemake \
        --configfile $1 --cores 4 \
        --use-singularity \
        --singularity-args "--bind ${HOME}:${HOME} --bind /mnt:/mnt" \
        --forceall \
        --printshellcmds \
        --rerun-incomplete \
        --snakefile $2 \
        --verbose
fi
