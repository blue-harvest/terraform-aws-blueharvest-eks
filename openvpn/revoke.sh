#!/usr/bin/env bash

CLIENT_NAME=$1

source ~/openvpn/vars

# And error ending in "ending in error 23" is expected
./revoke-full $CLIENT_NAME

# Install the revocation files
sudo cp ~/openvpn/keys/crl.pem /etc/openvpn

# Configure the server to check the client revocation list. This should only be done once
if [ $(grep -R 'crl-verify crl.pem' /etc/openvpn/server.conf | wc -l) -eq 0 ]; then
  echo "crl-verify crl.pem" >> /etc/openvpn/server.conf
  sudo systemctl restart openvpn@server
fi