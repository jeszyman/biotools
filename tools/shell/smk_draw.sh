# Draw rulegraph
# :PROPERTIES:
# :ID:       78a99954-1d5d-4e09-87a4-6690f28f4519
# :CUSTOM_ID: 78a99954-1d5d-4e09-87a4-6690f28f4519
# :END:


#  Note: This code block transcluded from code blocks in the Emacs Org-mode
#  file at https://github.com/jeszyman/biotools/blob/master/biotools.org.
#  Changes made directly to this region will be overwritten by transclusion from
#  the source blocks in that file.

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
    png=$(echo $3 | sed 's/.pdf/.png/g')
    conda activate snakemake
    #
    snakemake \
        --configfile $1 \
        --cores 1 \
        --rulegraph \
        --snakefile $2 | dot -Tpdf > $3
    #
    snakemake \
        --configfile $1 \
        --cores 1 \
        --rulegraph \
        --snakefile $2 | dot -Tpng > $png
fi
