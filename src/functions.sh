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
            (acl*) docker run -it \
                          --env HOME=${HOME} \
                          --hostname ${HOSTNAME} \
                          -v /drive3/:/drive3/ \
                          -v /duo4/:/duo4/ \
                          -v /home/:/home/ \
                          -u $(id -u ${USER}) \
                          $account/$container \
                          /bin/bash;;
            (ACL*) docker run -it \
                          --env HOME=${HOME} \
                          --hostname ${HOSTNAME} \
                          -v /home/:/home/ \
                          -v /duo4/:/duo4/ \
                          -u $(id -u ${USER}):$(id -g ${USER}) \
                          $account/$container \
                          /bin/bash;;
            (virtual-workstation*.gsc.wustl.edu) bsub -Is -q docker-interactive -a 'docker($account/'"$container"')' /bin/bash;;
            (*) docker run -it \
                       --env HOME=/home/${USER} \
                       --hostname ${HOSTNAME} \
                       --user $(id -u ${USER}) \
                       --volume /home/:/home/ \
                       --volume /mnt/:/mnt/ \
                       --volume /tmp/:/tmp/ \
                       $account/$container \
                       /bin/bash;;
        esac
    fi
}
