#!/bin/bash -xe


source $(dirname $(readlink -f ${0}))/common

SERVER="${DO_HOSTNAME}.${DO_DOMAIN}"
USER="root"


SERVER_RCON_PORT=16888
SERVER_RCON_PASSWORD="bobYep!"

MINECRAFT_DATA_DIR="/home/minecraft/server/data"

##########################################
# First stop minecraft server
#
# from mcrcon import MCRcon
# mcr = MCRcon("kraken.tc.pragmarob.com", "bobYep!", 16888)
# mcr.connect()
# mcr.command('/stop')
# mcr.disconnect()
#
#
minecraft_stop() {
    echo "Stop Minecraft server"
}

##########################################
# Backup world
minecraft_world_backup() {
    echo "Backup minecraft world"
    local output=${1}
    ssh_cmd ${USER} ${SERVER} "cd ${MINECRAFT_DATA_DIR} && tar czpf - world" > ${output}
    tar tzpf ${output} >> /dev/null
}

##########################################
# Shutdown server
server_shutdown() {
    echo "Server shutdown"
    ssh_cmd ${USER} ${SERVER} poweroff
}

##########################################
# Destroy droplet
destroy_droplet() {
    echo "Destroy droplet"
    doctl compute droplet delete ${DO_NAME} --force
}

##########################################
# Destroy domains
destroy_domain() {
    echo "Destroy domains"
    doctl compute domain delete ${DO_DOMAIN} --force
}

# minecraft_stop
#minecraft_world_backup ./world-$(date +%Y-%m-%d_%H-%m).tar.gz

if [ "x${FORCE}" == "x" ]; then
    server_shutdown
fi

destroy_droplet
destroy_domain

