#!/bin/bash

# check for root
if [[ $EUID -ne 0 ]]; then
    echo "this script must be run as root or with sudo"
    exit 1
fi

ssh_config="/etc/ssh/sshd_config"

ssh-keygen -t rsa -b 4096 -f "/home/cst8246/.ssh/id_rsa" -N ""

sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' "$ssh_config"
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' "$ssh_config"
sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' "$ssh_config"

systemctl enable sshd
systemctl restart sshd

# ssh-copy-id cst8246@pull0037-CLT.example48.lab
# ssh-copy-id cst8246@pull0037-SRV.example48.lab
