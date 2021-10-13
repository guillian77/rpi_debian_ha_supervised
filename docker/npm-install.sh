#!/usr/bin/env bash
###############################################################
#	Created by Richard Tirtadji
#   Auto installer for Raspberry on Debian 11 + HA Supervised  
# 	Installer scripts
# 	Additional script made by tteck
###############################################################
# Setup script environment
set -o errexit  #Exit immediately if a pipeline returns a non-zero status
set -o errtrace #Trap ERR from shell functions, command substitutions, and commands from subshell
set -o nounset  #Treat unset variables as an error
set -o pipefail #Pipe will exit with last non-zero status if applicable
shopt -s expand_aliases
alias die='EXIT=$? LINE=$LINENO error_exit'
trap die ERR
trap 'die "Script interrupted."' INT

function error_exit() {
  trap - ERR
  local DEFAULT='Unknown failure occured.'
  local REASON="\e[97m${1:-$DEFAULT}\e[39m"
  local FLAG="\e[91m[ERROR:HAInstall] \e[93m$EXIT@$LINE"
  msg "$FLAG $REASON"
  exit $EXIT
}
function msg() {
  local TEXT="$1"
  echo -e "$TEXT"
}

msg "Installing NGINX Proxy Manager..."
# Making Directory for docker container 
mkdir /usr/share/hassio/docker
mkdir /usr/share/hassio/docker/npm

# Installation portainer and watchtower
docker-compose /root/npm/docker-compose.yml up -d

# Cleanup container
msg "Cleanup..."
rm -rf /root/docker/npm-install.sh
msg " NGINX Proxy Manager Installed - \e[32m[DONE]\033[0m"
msg "First Login - email: admin@example.com and password: changeme"