# Check for parameters, return usage if empty
if [ "$#" -ne 2 ];
then
    printf "\n usage: smk_forced_run.sh <SMK CONFIG YAML> <SMK FILE>
    \n Script to complete an normal run of a snakefile
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
        --printshellcmds \
        --singularity-args "--bind ${HOME}:${HOME} --bind /mnt:/mnt" \
        --rerun-incomplete \
        --snakefile $2 \
        --verbose
fi
