docker_interactive() {
    if [ -f /.dockerenv ]; then
        echo "shell already in docker, exiting"
        exit 1
    else
        account="USER INPUT"
        container="USER INPUT"
        read -p "docker account name: " account
        account="${account:=jeszyman}"
        read -p "container name: " container
        container="${container:=biotools}"
        case $HOSTNAME in
            (radonc-cancerbio) docker run -it \
                                      --env HOME=${HOME} \
                                      --hostname ${HOSTNAME} \
                                      --user $(id -u ${USER}) \
                                      --volume /home/:/home/ \
                                      --volume /mnt/:/mnt/ \
                                      --volume /tmp/:/tmp/ \
                                      $account/$container \
                                      /bin/bash;;
            (jeszyman-*) docker run -it \
                                --env HOME=/home/jeszyman \
                                --hostname ${HOSTNAME} \
                                --user $(id -u ${USER}) \
                                --volume /home/:/home/ \
                                --volume /mnt/:/mnt/ \
                                --volume /tmp/:/tmp/ \
                                $account/$container \
                                /bin/bash;;
        (jeff-mac*) docker run -it \
                            --env HOME=/home/jeszyman \
                            --hostname ${HOSTNAME} \
                            --user $(id -u ${USER}) \
                            --volume /home/:/home/ \
                            --volume /mnt/:/mnt/ \
                            --volume /tmp/:/tmp/ \
                            jeszyman/$container \
                            /bin/bash;;        
        (acl*) docker run -it \
                      -v /drive3/:/drive3/ \
                      -v /duo4/:/duo4/ \
                      -v /home/:/home/ \
                      -u $(id -u ${USER}) \
                      jeszyman/$container \
                      /bin/bash;;
        (ACL*) docker run -it \
                      -v /home/:/home/ \
                      -v /duo4/:/duo4/ \
                      -u $(id -u ${USER}):$(id -g ${USER}) \
                      -h=${HOSTNAME} \
                      jeszyman/$container \
                      /bin/bash;;
        (virtual-workstation*.gsc.wustl.edu) bsub -Is -q docker-interactive -a 'docker(jeszyman/'"$container"')' /bin/bash;;
        esac
    fi
}
