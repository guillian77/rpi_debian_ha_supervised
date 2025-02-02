#!/usr/bin/env bash
###############################################################
#	Created by Richard Tirtadji
#   Auto installer for Raspberry on Debian 11 + HA Supervised  
# 	Installer scripts
# 	Additional script made by tteck
###############################################################
TZONE=$1
KEY_YES=$2
PUB_KEY=$3
HOST_NAME=$4
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

msg "Main Setup Begin..."

while [[ $TZONE = "" ]]; do
  read -p "Write your timezone eg, Asia/Jakarta: " TZONE
done

while [[ $HOST_NAME = "" ]]; do
  read -p "The name of your server host eg. Home-Assistant: " HOST_NAME
done

# setup locales choose en-US.UTF-8
locale-gen "en_US.UTF-8"
dpkg-reconfigure locales
msg "Locale Set - \e[32m[DONE]\033[0m"

# Make Link for MOTD apps
ln -s /usr/games/lolcat /usr/bin/lolcat
ln -s /usr/games/fortune /usr/bin/fortune
ln -s /usr/games/cowsay /usr/bin/cowsay
ln -s /usr/games/cowthink /usr/bin/cowthink
msg "Link for MOTD Set - \e[32m[DONE]\033[0m"

# Setup time for my timezone
timedatectl set-timezone $TZONE
msg "Time Zone Set - \e[32m[DONE]\033[0m"

# Implement SSH Keys
read -p "Do you want to used SSH Key for a better security? (y/n): " KEY_YES

if [ "$KEY_YES" != "${KEY_YES#[Yy]}" ]; then

while [[ $PUB_KEY = "" ]]; do
  read -p "Write your public key (long string of code starting with ssh-rsa), eg. ssh-rsa: " PUB_KEY
done

# Continue installations
SSH_ROOT=~/.ssh

[ ! -d "$SSH_ROOT" ] && mkdir -p "$SSH_ROOT"
chmod 700 $SSH_ROOT 
cat <<EOF >$SSH_ROOT/authorized_keys
$PUB_KEY
EOF

chmod 600 $SSH_ROOT/authorized_keys

sed -i 's/#\?\(PermitRootLogin\s*\).*$/\1 yes/' /etc/ssh/sshd_config
sed -i 's/#\?\(PermitEmptyPasswords\s*\).*$/\1 no/' /etc/ssh/sshd_config
sed -i 's/#\?\(PasswordAuthentication\s*\).*$/\1 no/' /etc/ssh/sshd_config
sed -i 's/#\?\(Banner\s*\).*$/\1 \/etc\/issue.net/' /etc/ssh/sshd_config

echo "KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256" >> /etc/ssh/sshd_config
echo "MACs umac-128-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,umac-128@openssh.com,hmac-sha2-256,hmac-sha2-512" >> /etc/ssh/sshd_config

else

# Continue installations
sed -i 's/#\?\(PermitRootLogin\s*\).*$/\1 yes/' /etc/ssh/sshd_config
sed -i 's/#\?\(PermitEmptyPasswords\s*\).*$/\1 yes/' /etc/ssh/sshd_config
sed -i 's/#\?\(PasswordAuthentication\s*\).*$/\1 no/' /etc/ssh/sshd_config
sed -i 's/#\?\(Banner\s*\).*$/\1 \/etc\/issue.net/' /etc/ssh/sshd_config

echo "KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256" >> /etc/ssh/sshd_config
echo "MACs umac-128-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,umac-128@openssh.com,hmac-sha2-256,hmac-sha2-512" >> /etc/ssh/sshd_config

fi
msg "SSH Set - \e[32m[DONE]\033[0m"


# Setting MOTD
rm -rf /etc/update-motd.d/10* /etc/update-motd.d/50* /etc/update-motd.d/80* 
cp $PWD/motd/* /etc/update-motd.d/ 
chmod +x /etc/update-motd.d/*
msg "MOTD Set - \e[32m[DONE]\033[0m"

# HOSTNAME setup
hostnamectl set-hostname $HOST_NAME
echo "127.0.0.1 $HOST_NAME" >> /etc/hosts
msg "Hostname Set - \e[32m[DONE]\033[0m"

# Making a new banner
cat <<EOF >/etc/issue.net
###############################################################
#  Welcome to $HOST_NAME                 
#                                                             
#  All connections are monitored and recorded          
#                                                             
#  Disconnect IMMEDIATELY if you are not an authorized user!  
###############################################################
EOF
msg "SSH Banner Set - \e[32m[DONE]\033[0m"

systemctl restart ssh
systemctl disable rpi-set-sysconf

msg "Main Setup - \e[32m[DONE]\033[0m"