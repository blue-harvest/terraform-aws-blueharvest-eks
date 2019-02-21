#!/usr/bin/env bash

echo "127.0.0.1 $(hostname)" | sudo tee -a /etc/hosts
echo "............ STEP 1 - Installing Open VPN ............"

sudo apt-get -y update

sudo DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
sudo DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade

sudo apt-get -y update

sudo apt-get -y install openvpn easy-rsa expect