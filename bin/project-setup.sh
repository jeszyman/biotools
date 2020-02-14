#!/bin/bash
#
#############################################################################
###              BIOINFORMATICS PROJECT COMMON SETUP SCRIPT               ###
#############################################################################
#
###############
### SCRIPTS ###
###############
#
# Interactive docker initialization
docker_interactive() {
    repo="USER INPUT"
    read -p "repo name: " repo
    case $HOSTNAME in
        (radonc-cancerbio) docker run -it \
                                  -v /media/:/media/ \
                                  -v /home/:/home/ \
                            -u $(id -u ${USER}) \
                            jeszyman/$repo \
                            /bin/bash;;
        (jeszyman-*) docker run -it \
                            -v /home/:/home/ \
                            -u $(id -u ${USER}) \
                            jeszyman/$repo \
                            /bin/bash;;
        (acl*) docker run -it \
                      -v /drive3/:/drive3/ \
                      -v /duo4/:/duo4/ \
                      -v /home/:/home/ \
                      -u $(id -u ${USER}) \
                      jeszyman/$repo \
                      /bin/bash;;
        (ACL*) docker run -it \
                      -v /home/:/home/ \
                      -v /duo4/:/duo4/ \
                      -u $(id -u ${USER}):$(id -g ${USER}) \
                      -h=${HOSTNAME} \
                      jeszyman/$repo \
                      /bin/bash;;
        (virtual-workstation*.gsc.wustl.edu) bsub -Is -q docker-interactive -a 'docker(jeszyman/'"$repo"')' /bin/bash;;
    esac
}
#
#
echo "Biotools setup completed successfully"
#
############################################################################
#
#############
### IDEAS ###
#############
# # identifies server in docker containers
# server_ask() {
#     echo -n "Choose your server: "
#     read SERVER
#     SERVER="${SERVER:=chaudhuri-roche}"
# }
# # check if inside docker
# if [ -f /.dockerenv ];then 
#     dockercontainer=yes
#     echo "Your are in a docker container"    
# else 
#     dockercontainer=no
#     echo "Not in docker"
#     # setup NON-docker variables 
#     shopt -s nocasematch
#     case $HOSTNAME in
#         (radonc-cancerbio) server_home="/home/jeszyman" ;;
#         (jeszyman-*) server_home="/home/jeszyman" ;;
#         (acl*) server_home="/home/jszymanski" ;; 
#         (virtual-workstation*.gsc.wustl.edu) server_home="/gscuser/szymanski" ;;
#         (blade*.gsc.wustl.edu) server_home="/gscuser/szymanski" ;;
#     esac
#     projectdir=$server_home"/repos/$project"
#     localdata="$server_home/data/$project/"
#     unset $SERVER
# fi
# #
# case $dockercontainer in
#     (yes) server_ask ;;
#     (no) ;;
# esac
# #
# case $SERVER in
#     (chaudhuri-roche) projectdir=/drive3/users/jszymanski/repos/$project
#                       localdata=/drive3/users/jszymanski/data/$project;;
#     (NA) ;;
# esac
#
#IDEAS
### DEPENDENCIES ### 
#declare -a software=(
#"rclone"
# #DOES NOT RETURN ON MGI                     "docker"
# #"git"
# "bash"
# )
# for i in "${software[@]}"; do
# if command -v $i >/dev/null 2>&1 ; then
#     echo "$i installed"
# else
#     echo "$i not found, exiting"
#     exit 1
# fi
# done
