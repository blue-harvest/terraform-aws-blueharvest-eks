#!/usr/bin/env bash

echo "............ STEP 2 - Configuring CA ............"

KEY_COUNTRY="NL"
KEY_PROVINCE="North Holland"
KEY_CITY="Amsterdam"
KEY_ORG="Blue Harvest"
KEY_EMAIL="vpn@blueharvest.io"
KEY_OU="Blue Harvest"

PUBLIC_IP=$1
CLIENT_NAME=$2

# Update vars
sed -i "s/export KEY_COUNTRY=\"[^\"]*\"/export KEY_COUNTRY=\"${KEY_COUNTRY}\"/" ~/openvpn/vars
sed -i "s/export KEY_PROVINCE=\"[^\"]*\"/export KEY_PROVINCE=\"${KEY_PROVINCE}\"/" ~/openvpn/vars
sed -i "s/export KEY_CITY=\"[^\"]*\"/export KEY_CITY=\"${KEY_CITY}\"/" ~/openvpn/vars
sed -i "s/export KEY_ORG=\"[^\"]*\"/export KEY_ORG=\"${KEY_ORG}\"/" ~/openvpn/vars
sed -i "s/export KEY_EMAIL=\"[^\"]*\"/export KEY_EMAIL=\"${KEY_EMAIL}\"/" ~/openvpn/vars
sed -i "s/export KEY_OU=\"[^\"]*\"/export KEY_OU=\"${KEY_OU}\"/" ~/openvpn/vars
sed -i "s/export KEY_NAME=\"[^\"]*\"/export KEY_NAME=\"server\"/" ~/openvpn/vars

source ~/openvpn/vars

ls -l ~/openvpn
cat ~/openvpn/vars

################################ Build the Certificate Authority ################################
echo "............ STEP 3 - Generating Server Certificates ............"

~/openvpn/clean-all

yes "" | ./build-ca

./build-server-key.sh

~/openvpn/build-dh

openvpn --genkey --secret ~/openvpn/keys/ta.key

cd  ~/openvpn
ls -la ~/openvpn/keys

################################ Copy the files to the OpenVPN directory ################################

echo "............ STEP 4 - Preparing Server Configuration ............"

sudo cp ~/openvpn/keys/ca.crt ~/openvpn/keys/ca.key ~/openvpn/keys/server.crt ~/openvpn/keys/server.key ~/openvpn/keys/ta.key ~/openvpn/keys/dh2048.pem /etc/openvpn
sudo gunzip -c /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz | sudo tee /etc/openvpn/server.conf

################################ Adjust the OpenVPN configuration ################################
echo "............ STEP 5 - Configuring Server  ............"

sudo sed -i "s/;tls-auth ta.key 0/tls-auth ta.key 0\nkey-direction 0/" /etc/openvpn/server.conf
sudo sed -i "s/;cipher AES-128-CBC/cipher AES-128-CBC\nauth SHA256/" /etc/openvpn/server.conf
sudo sed -i "s/;user nobody/user nobody/" /etc/openvpn/server.conf
sudo sed -i "s/;group nogroup/group nogroup/" /etc/openvpn/server.conf
sudo sed -i "s/;duplicate-cn/duplicate-cn/" /etc/openvpn/server.conf
sudo sed -i "s/;push \"route 192.168.10.0 255.255.255.0\"/push \"route 10.0.0.0 255.255.0.0\"/" /etc/openvpn/server.conf

################################ Allow IP forwarding ################################
echo "............ STEP 6 - Configuring IP forwarding  ............"

source ./interfaces.sh

sudo sed -i "s/#net.ipv4.ip_forward/net.ipv4.ip_forward/" /etc/sysctl.conf
sudo sysctl -p

#Install iptables-persistent so that rules can persist across reboots
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections

sudo apt-get install -y iptables-persistent

#Edit iptables rules to allow for forwarding
sudo iptables -t nat -A POSTROUTING -o tun+ -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -o $VPNDEVICE -j MASQUERADE

#Make iptables rules persistent across reboots
sudo iptables-save | sudo tee -a /etc/iptables/rules.v4

################################ Start and enable the OpenVPN service ################################
echo "............ STEP 7 - Starting Open VPN Server  ............"

sudo systemctl start openvpn@server
sudo systemctl enable openvpn@server
sudo systemctl status openvpn@server | cat

################################ Prepare clients folder ################################
echo "............ STEP 8 - Preparing clients config  ............"

source ~/openvpn/vars
mkdir -p ~/client-configs/files

cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf ~/client-configs/base.conf

sed -i "s/remote my-server-1 1194/remote ${PUBLIC_IP} 1194/" ~/client-configs/base.conf
sed -i "s/;user nobody/user nobody/" ~/client-configs/base.conf
sed -i "s/;group nogroup/group nogroup/" ~/client-configs/base.conf
sed -i "s/ca ca.crt/#ca ca.crt/" ~/client-configs/base.conf
sed -i "s/cert client.crt/#cert client.crt/" ~/client-configs/base.conf
sed -i "s/key client.key/#key client.key/" ~/client-configs/base.conf

echo "cipher AES-128-CBC" >> ~/client-configs/base.conf
echo "auth SHA256" >> ~/client-configs/base.conf
echo "key-direction 1" >> ~/client-configs/base.conf
echo "#script-security 2" >> ~/client-configs/base.conf
echo "#up /etc/openvpn/update-resolv-conf" >> ~/client-configs/base.conf
echo "#down /etc/openvpn/update-resolv-conf" >> ~/client-configs/base.conf

ls -la ~/client-configs/files

################################ Restart Open VPN ##########################################
echo "............ STEP 9 - Restarting Open VPN Server  ............"
sudo systemctl restart openvpn@server
sudo systemctl status openvpn@server | cat

################################ Generate client config ####################################
echo "............ STEP 10 - Generating clients config  ............"
source ~/openvpn/vars

KEY_DIR=~/openvpn/keys
OUTPUT_DIR=~/client-configs/files
BASE_CONFIG=~/client-configs/base.conf

./build-client-key.sh $CLIENT_NAME

cat ${BASE_CONFIG} \
    <(echo -e '<ca>') \
    ${KEY_DIR}/ca.crt \
    <(echo -e '</ca>\n<cert>') \
    ${KEY_DIR}/${CLIENT_NAME}.crt \
    <(echo -e '</cert>\n<key>') \
    ${KEY_DIR}/${CLIENT_NAME}.key \
    <(echo -e '</key>\n<tls-auth>') \
    ${KEY_DIR}/ta.key \
    <(echo -e '</tls-auth>') \
    > ${OUTPUT_DIR}/${CLIENT_NAME}.ovpn

ls -la ~/client-configs/files