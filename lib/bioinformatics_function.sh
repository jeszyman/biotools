# Bioinformatic shell functions
# :PROPERTIES:
# :header-args: :tangle ./lib/bioinformatics_function.sh :tangle-mode (identity #o555) :mkdirp yes :noweb yes :comments org
# :ID:       2e51c010-1e25-4fc3-acc5-aefd490164be
# :END:


# Functions

function conda_update() {
      [[ "$1" =~ (-h|--help) || -z "$1" ]] && {
    cat <<EOF
Usage: conda_update <ENV YAML>
Updates a conda environment yaml file using mamba
EOF
    return
      }
      local file="${1}"
      eval "$(command conda \"shell.bash\" \"hook\" 2> /dev/null)"
      conda activate base
      mamba env update --file $file
}

smk_draw(){
  [[ "$1" =~ (-h|--help) || -z "$1" ]] && {
    cat <<EOF
Usage: smk_draw <CONFIG FILE> <SNAKEFILE>
Implements snakemake's rulegraph to make a DAG. DAG is saved in ./resources/<SNAKEFILE BASENAME>.pdf and .png
EOF
    return
  }
    local configfile="${1}"
    local snakefile="${2}"
    local snakefile_basename="$(basename "$snakefile")"
    local out_pdf="./resources/${snakefile_basename%.*}_smk.pdf"
    local out_png="${out_pdf%.*}.png"
    snakemake --configfile "$configfile" \
              --snakefile "$snakefile" \
              --cores 1 \
              --rerun-incomplete \
              --dry-run \
              --quiet \
              --rulegraph | tee >(dot -Tpdf > "$out_pdf") | dot -Tpng > "$out_png"
}

smk_dry(){
    local configfile="${1}"
    local snakefile="${2}"
    snakemake \
        --configfile $configfile \
        --cores 4 \
        --dry-run \
        --rerun-incomplete \
        --snakefile $snakefile
}

smk_forced(){
    local configfile="${1}"
    local snakefile="${2}"
    local cores=$(nproc)
    snakemake \
        --configfile "$configfile" \
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
    local configfile="${1}"
    local snakefile="${2}"
    local cores=$(nproc)
    snakemake \
        --configfile "$configfile" \
        --cores "$cores" \
        --keep-going \
        --rerun-incomplete \
        --snakefile "$snakefile"
}

# Tangle the specified org file using Emacs and org-mode
# Usage: tangle <org_file>
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

# Check if mount is active

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
