#!/usr/bin/env bash
set -o errexit   # abort on nonzero exitstatus
set -o pipefail  # don't hide errors within pipes

declare_variables() {
    repo=$1
}

main(){
    declare_variables $1
    make_base $repo
    make_sub $repo
}

print_usage(){
    cat <<- EOF

usage: make_biopipe_dirs.sh <REPOSITORY PATH>

Make bioinformatics pipeline repository directory structure

example: make_biopipe_dirs.sh ~/repos/rna-seq

EOF
}

make_base(){
    if [ ! -d $repo ];
    then
        mkdir -p $repo
    fi
}

make_sub(){
    mkdir -p "${repo}/config"
    mkdir -p "${repo}/resources"
    mkdir -p "${repo}/workflow"
    mkdir -p "${repo}/scripts"
    mkdir -p "${repo}/test/inputs"
    mkdir -p "${repo}/test/logs"
    mkdir -p "${repo}/test/analysis"
}

# Run
[ "$1" = -h ] && print_usage && exit 1
[ ! "$#" -eq 1 ] && print_usage && exit 1
main "$@"
