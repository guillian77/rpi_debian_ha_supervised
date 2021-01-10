#!/bin/bash
###############################################################
#	Created by Richard Tirtadji
#   Auto installer for Raspberry on Debian 10 + HA Supervised  
#   Install Watchtower Docker
###############################################################
# Installation watchtower with interval 7200 seconds
docker run --name="watchtower" -d --restart=always -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --interval 7200

echo -e "Watchtower installed \e[32m[DONE]\033[0m"