smk_draw(){
  [[ "$1" =~ (-h|--help) || -z "$1" ]] && {
    cat <<EOF
Usage: smk_draw <CONFIG FILE> <SNAKEFILE>
Implements snakemake's rulegraph to make a DAG. DAG is saved in ./resources/<SNAKEFILE BASENAME>.pdf and .png
EOF
    return
  }
    local snakefile="${1}"
    local snakefile_basename="$(basename "$snakefile")"
    local out_pdf="./resources/${snakefile_basename%.*}_smk.pdf"
    local out_png="${out_pdf%.*}.png"
    snakemake --configfile ./config/${HOSTNAME}.yaml \
              --snakefile "$snakefile" \
              --cores 1 \
              --rerun-incomplete \
              --dry-run \
              --quiet \
              --rulegraph | tee >(dot -Tpdf > "$out_pdf") | dot -Tpng > "$out_png"
}

smk_dry(){
    local snakefile="${1}"
    snakemake \
        --configfile ./config/${HOSTNAME}.yaml \
        --cores 4 \
        --dry-run \
        --rerun-incomplete \
        --snakefile $snakefile
}

smk_forced(){
    local snakefile="${1}"
    local cores=$(nproc)
    snakemake \
        --configfile ./config/${HOSTNAME}.yaml \
        --cores "$cores" \
        --forceall \
        --rerun-incomplete \
        --snakefile "$snakefile"
}

smk_run(){
  [[ "$1" =~ (-h|--help) || -z "$1" ]] && {
    cat <<EOF
Usage: smk_run <CONFIGFILE> <SNAKEFILE>
Launches a snakemake run with common parameters
(keep-going, rerun-incomplete, use all available cores)
EOF
    return
  }
    local snakefile="${1}"
    local cores=$(nproc)
    snakemake \
        --configfile ./config/${HOSTNAME}.yaml \
        --cores "$cores" \
        --keep-going \
        --rerun-incomplete \
        --snakefile "$snakefile"
}

tangle() {
  [[ "$1" =~ (-h|--help) || -z "$1" ]] && {
    cat <<EOF
Usage: tangle <ORG FILE>
Tangle's org-mode file code using a non-interactive emacs batch instance
EOF
    return
  }
    local org_file="$1"
    /usr/bin/emacs --batch -l ~/.emacs.d/tangle.el -l org -eval "(org-babel-tangle-file \"$org_file\")"
}

check_mnt(){
  [[ "$1" =~ (-h|--help) || -z "$1" ]] && {
    cat <<EOF
Usage: check_mnt <DIRECTORY>
Checks if directory is a mount point (must be top directory of mtn).
EOF
    return
  }
    local directory="${1}"
    if mountpoint -q "$directory"; then
        echo "The directory $directory is a mountpoint."
    else
        echo "The directory $directory is not a mountpoint."
    fi
}
