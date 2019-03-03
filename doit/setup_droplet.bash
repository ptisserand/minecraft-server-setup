#!/bin/bash -xe

PROJ_DIR=$(dirname $(readlink -f ${0}))
source ${PROJ_DIR}/common

SERVER="${DO_HOSTNAME}.${DO_DOMAIN}"
USER="root"
DROPLET_IP=xxxxxxx

USER_DATA_FILE_TPL=${PROJ_DIR}/minecraft-setup.sh.in
USER_DATA_FILE=${PROJ_DIR}/minecraft-setup.sh
##########################################
# Generate user data file
generate_user_data_file() {
    sed "s|@LOCAL_RCON_PASSWORD@|${RCON_PASSWORD}|g" ${USER_DATA_FILE_TPL} > ${USER_DATA_FILE}
}

##########################################
# Create droplet
create_droplet() {
    echo "Create droplet"
    if [ "x${NO_USER_DATA}" == "x" ]; then
        doctl compute droplet create ${DO_NAME} --tag-name ${DO_TAG} \
                                        --ssh-keys ${DO_SSH_KEY} \
                                        --region ${DO_REGION} \
                                        --size ${DO_SIZE} \
                                        --image ${DO_IMAGE} --wait -v \
                                        --user-data-file ${USER_DATA_FILE}
    else
        doctl compute droplet create ${DO_NAME} --tag-name ${DO_TAG} \
                                        --ssh-keys ${DO_SSH_KEY} \
                                        --region ${DO_REGION} \
                                        --size ${DO_SIZE} \
                                        --image ${DO_IMAGE} --wait -v
    fi
}

get_ip() {
    echo "Get IP"
    DROPLET_IP=$(doctl compute droplet list ${DO_NAME} --no-header --format PublicIPv4)
}
##########################################
# Create domain
create_domain() {
    echo "Create domain"
    doctl compute domain create ${DO_DOMAIN} --ip-address ${DROPLET_IP}
}

##########################################
# Setup DNS
setup_dns() {
    echo "Setup DNS"
    doctl compute domain records create ${DO_DOMAIN} --record-type A --record-name ${DO_HOSTNAME} --record-data ${DROPLET_IP} --verbose
}


generate_user_data_file
create_droplet
get_ip
create_domain
setup_dns
