#!/usr/bin/env bash

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

print_usage(){
    cat <<- EOF

###################################################
###   Docker and Singularity Building Command   ###
###################################################

Steps
1) Builds docker container
2) Pushes container to dockerhub
3) Builds singularity file
4) Pushes singularity file to box

usage: docker_build.sh [options] <DOCKER FILE> <DOCKER TAG> <OPIONAL - DOCKER BUILD LOC>
  options:
    -n  No cache, use for validation of full build
    -s  A sif directory location
    -v  Docker version, a version appended to docker and singularity tags
        Note: adding a version will push the singularity build to
        shared/singularity-containers/stable

example:

docker_build.sh -n -s ~/sing_containers -v 2.0.0 ~/dockerfiles/atac_Dockerfile jeszyman/atac ~/docker_bulid_dir

EOF
}

# Setup options
while getopts "nt:v:s:" options;
do
    case "${options}" in
        n) usecache="--no-cache" ;;
        v) version=${OPTARG} ;;
        s) sifdir=${OPTARG} ;;
        \?)
            echoerr "Invalid option -$OPTARG"
            print_usage
            exit 1
            ;;
    esac
done

shift $((OPTIND -1))

[[ $# -eq 0 ]] && print_usage && exit 1

# Scipt variables
dockerfile=$1
tag=$2
if [ -z ${usecache+x} ]; then usecache="cache"; fi
dockerloc="${3:-.}"

main(){

    # Build and push docker container. Append version if provided.
    printf "\nBuilding Docker container now...\n"
    sleep 2s
    if [ -z ${version+x} ]
    then
        build_docker $dockerfile $tag $dockerloc $usecache
        docker push $tag
    else
        build_docker $dockerfile $tag:$version $dockerloc $usecache
        docker push $tag:$version
    fi

    # Build and push sif if provided.

    if [ -z ${sifdir+x} ];

    then
        printf "\ns is unset, nothing more to do.\n"
    else
        printf "\nBuilding Singularity container now...\n"
        sleep 2s
        build_singularity $sifdir \
                          $tag
        printf "\nLocal Singularity build complete.\nPushing singularity to box...\n"
        push_singularity $sifdir \
                         $tag \
                         "shared/singularity-containers"
    fi
}

build_docker(){
    local dockerfile="${1}"
    local dockertag="${2}"
    local dockerloc="${3}"
    if [ $4 == "--no-cache" ];
    then
        docker build \
               --file $dockerfile $4 \
               --pull \
               --tag $dockertag \
               $dockerloc
    else
        docker build \
               --file $dockerfile \
               --pull \
               --tag $dockertag \
               $dockerloc
    fi
}

push_docker(){
    local dockertag="${1}"
    docker push $dockertag
}

build_singularity(){
    local sifdir="${1}"
    local dockertag="${2}"
    if [ -z ${version+x} ];
    then
        siftag=$(echo $dockertag | sed 's/^.*\///g')
    else
        siftag=$(echo $dockertag.$version | sed 's/^.*\///g')
    fi
    singularity pull \
                --force \
                "${sifdir}/${siftag}.sif" \
                "docker://${dockertag}"
}

push_singularity(){
    local sifdir=${1}
    local dockertag=${2}
    local targetbase="${3}"
    if [ -z ${version+x} ];
    then
        siftag=$(echo $dockertag | sed 's/^.*\///g')
        target=$(echo "${targetbase}/most-recent/")
    else
        siftag=$(echo $dockertag.$version | sed 's/^.*\///g')
        target=$(echo "${targetbase}/stable/")
    fi

    rclone copy \
           --update \
           --verbose \
           "${sifdir}/${siftag}.sif" remote:"${target}"
}

main "$@"
