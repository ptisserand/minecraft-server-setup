#!/bin/bash -e

source $(dirname $(readlink -f ${0}))/common

SERVER="${DO_HOSTNAME}.${DO_DOMAIN}"
USER="root"

MINECRAFT_DATA_DIR="/home/minecraft/server/data"

##########################################
# Backup world
minecraft_world_backup() {
    local output=${1}
    echo "Backup minecraft world into ${output}"
    ssh_cmd ${USER} ${SERVER} "cd ${MINECRAFT_DATA_DIR} && tar czpf - world" > ${output}
    tar tzpf ${output} >> /dev/null
}


if test $# -ne 1; then
    echo "${0} require 1 argument"
    exit 1
fi

minecraft_world_backup ${1}

