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
  local FLAG="\e[91m[ERROR:LXC] \e[93m$EXIT@$LINE"
  msg "$FLAG $REASON"
  exit $EXIT
}
function msg() {
  local TEXT="$1"
  echo -e "$TEXT"
}

apt install -y nginx &>/dev/null

cp -r ~/nginx-files/custom-snippets /etc/nginx/
cp ~/nginx-files/dhparam4096.pem /etc/ssl/certs/
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
cp ~/nginx-files/nginx.conf /etc/nginx/
msg "Add files and backup for NGINX - \e[32m[DONE]\033[0m"

service nginx restart
msg "NGINX Installed - \e[32m[DONE]\033[0m"

# Cleanup container
msg "Cleanup..."
rm -rf /root/install/certbot-install.sh