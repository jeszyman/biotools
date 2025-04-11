# Built docker container
# :PROPERTIES:
# :ORDERED:  t
# :ID:       d9400316-b6a3-4922-a20d-c2f203259f6a
# :END:

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

usage: docker_build.sh [options] <DOCKER FILE> <DOCKER TAG> [OPTIONAL - DOCKER BUILD LOC]
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
        h | *) print_usage; exit 0 ;;
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
    printf "\nBuilding Docker container now...\n "
    sleep 2s
    if [ -z ${version+x} ]
    then
        build_docker $dockerfile $tag $dockerloc $usecache
        printf "\nPushing docker container to dockerhub...\n "
        docker push $tag
    else
        build_docker $dockerfile "${tag}:${version}" $dockerloc $usecache
        printf "\nPushing docker container to dockerhub...\n "
        docker push $tag:$version
    fi

    # Build and push sif if provided.

    if [ -z ${sifdir+x} ];
    then
        sleep 2s
        printf "\n-s flag is unset, nothing more to do.\n "
    else
        dockertag="$tag"
        if [ -z ${version+x} ];
        then
            siftag=$(echo $tag | sed 's/^.*\///g')
            target="shared/singularity-containers/most-recent/"
        else
            presiftag=$(echo $tag | sed 's/^.*\///g')
            siftag="${presiftag}.${version}"
            target="shared/singularity-containers/stable/"
        fi

        printf "\nBuilding Singularity container now...\n"

        build_singularity $sifdir \
                          $siftag \
                          $dockertag

        sleep 2s
        echo "build_singularity $sifdir $siftag $dockertag"
        printf "\nLocal Singularity build complete.\nPushing singularity to box...\n"

        push_singularity $sifdir \
                         $siftag \
                         $target

    fi
}

# main(){


#     # Build and push sif if provided.

#     if [ -z ${sifdir+x} ];

#     then
#         sleep 2s
#         printf "\n-s flag is unset, nothing more to do.\n "
#     else
#         dockertag="$tag"
#         if [ -z ${version+x} ];
#         then
#             siftag="$tag"
#             target="shared/singularity-containers/most-recent"
#         else
#             siftag="${tag}.${version}"
#             target="shared/singularity-containers/stable"
#         fi
#         printf "\nBuilding Singularity container now...\n"
#         sleep 2s
#         build_singularity $sifdir \
#                           $siftag \
#                           $dockertag
#         printf "\nLocal Singularity build complete.\nPushing singularity to box...\n"
#         push_singularity $sifdir \
#                          $siftag \
#                          $target
#     fi
# }

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
    local siftag="${2}"
    local dockertag="${3}"
    singularity pull \
                --force \
                "${sifdir}/${siftag}.sif" \
                "docker://${dockertag}"
}

push_singularity(){
    local sifdir="${1}"
    local siftag="${2}"
    local target="${3}"
    rclone copy \
           --update \
           --verbose \
           "${sifdir}/${siftag}.sif" remote:"${target}"
}

main "$@"
# Built docker container
# :PROPERTIES:
# :ORDERED:  t
# :ID:       ef485b0c-90af-4295-8e53-a4149cb179af
# :END:

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

usage: docker_build.sh [options] <DOCKER FILE> <DOCKER TAG> [OPTIONAL - DOCKER BUILD LOC]
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
        h | *) print_usage; exit 0 ;;
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
    printf "\nBuilding Docker container now...\n "
    sleep 2s
    if [ -z ${version+x} ]
    then
        build_docker $dockerfile $tag $dockerloc $usecache
        printf "\nPushing docker container to dockerhub...\n "
        docker push $tag
    else
        build_docker $dockerfile "${tag}:${version}" $dockerloc $usecache
        printf "\nPushing docker container to dockerhub...\n "
        docker push $tag:$version
    fi

    # Build and push sif if provided.

    if [ -z ${sifdir+x} ];
    then
        sleep 2s
        printf "\n-s flag is unset, nothing more to do.\n "
    else
        dockertag="$tag"
        if [ -z ${version+x} ];
        then
            siftag=$(echo $tag | sed 's/^.*\///g')
            target="shared/singularity-containers/most-recent/"
        else
            presiftag=$(echo $tag | sed 's/^.*\///g')
            siftag="${presiftag}.${version}"
            target="shared/singularity-containers/stable/"
        fi

        printf "\nBuilding Singularity container now...\n"

        build_singularity $sifdir \
                          $siftag \
                          $dockertag

        sleep 2s
        echo "build_singularity $sifdir $siftag $dockertag"
        printf "\nLocal Singularity build complete.\nPushing singularity to box...\n"

        push_singularity $sifdir \
                         $siftag \
                         $target

    fi
}

# main(){


#     # Build and push sif if provided.

#     if [ -z ${sifdir+x} ];

#     then
#         sleep 2s
#         printf "\n-s flag is unset, nothing more to do.\n "
#     else
#         dockertag="$tag"
#         if [ -z ${version+x} ];
#         then
#             siftag="$tag"
#             target="shared/singularity-containers/most-recent"
#         else
#             siftag="${tag}.${version}"
#             target="shared/singularity-containers/stable"
#         fi
#         printf "\nBuilding Singularity container now...\n"
#         sleep 2s
#         build_singularity $sifdir \
#                           $siftag \
#                           $dockertag
#         printf "\nLocal Singularity build complete.\nPushing singularity to box...\n"
#         push_singularity $sifdir \
#                          $siftag \
#                          $target
#     fi
# }

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
    local siftag="${2}"
    local dockertag="${3}"
    singularity pull \
                --force \
                "${sifdir}/${siftag}.sif" \
                "docker://${dockertag}"
}

push_singularity(){
    local sifdir="${1}"
    local siftag="${2}"
    local target="${3}"
    rclone copy \
           --update \
           --verbose \
           "${sifdir}/${siftag}.sif" remote:"${target}"
}

main "$@"
