#########1#########2#########3#########4#########5#########6#########7#########8
# Interactive docker initialization
#  TODO- set so docker username not restricted
#  TODO- set a no server condition
docker_interactive() {
    repo="USER INPUT"
    read -p "repo name: " repo
    case $HOSTNAME in
        (radonc-cancerbio) docker run -it \
                                  --env HOME=${HOME} \
                                  --hostname ${HOSTNAME} \
                                  --user $(id -u ${USER}) \
                                  --volume /home/:/home/ \
                                  --volume /mnt/:/mnt/ \
                                  --volume /tmp/:/tmp/ \
                                  jeszyman/$repo \
                                  /bin/bash;;
        (jeszyman-*) docker run -it \
                            --env HOME=/home/jeszyman \
                            --hostname ${HOSTNAME} \
                            --user $(id -u ${USER}) \
                            --volume /home/:/home/ \
                            --volume /mnt/:/mnt/ \
                            --volume /tmp/:/tmp/ \
                            jeszyman/$repo \
                            /bin/bash;;
        (jeff-mac*) docker run -it \
                            --env HOME=/home/jeszyman \
                            --hostname ${HOSTNAME} \
                            --user $(id -u ${USER}) \
                            --volume /home/:/home/ \
                            --volume /mnt/:/mnt/ \
                            --volume /tmp/:/tmp/ \
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
