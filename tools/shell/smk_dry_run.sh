# Dry run
# :PROPERTIES:
# :ID:       c6c494f0-5dbe-4cc4-bf99-8bcd7b12de24
# :END:


#  Note: This code block transcluded from code blocks in the Emacs Org-mode
#  file at https://github.com/jeszyman/biotools/blob/master/biotools.org.
#  Changes made directly to this region will be overwritten by transclusion from
#  the source blocks in that file.

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
