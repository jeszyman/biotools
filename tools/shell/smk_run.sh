# TODO [#D] Normal run
# :PROPERTIES:
# :effort:   00:30
# :ID:       3adf72d3-aa35-4a3d-8eba-0df075c52e26
# :CUSTOM_ID: 3adf72d3-aa35-4a3d-8eba-0df075c52e26
# :END:

# - [ ] needs a cores option w/ default

#  Note: This code block transcluded from code blocks in the Emacs Org-mode
#  file at https://github.com/jeszyman/biotools/blob/master/biotools.org.
#  Changes made directly to this region will be overwritten by transclusion from
#  the source blocks in that file.

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
        --resources mem_mb=6000 \
        --snakefile $2 \
        --verbose
fi
