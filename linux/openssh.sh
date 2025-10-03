#!/bin/bash

# check for root
if [[ $EUID -ne 0 ]]; then
    echo "this script must be run as root or with sudo"
    exit 1
fi

ssh_config="/etc/ssh/sshd_config"
alias_ip="172.16.32.48"

ssh-keygen -t rsa -b 4096 -f "/home/cst8246/.ssh/id_rsa" -N ""

sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' "$ssh_config"
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' "$ssh_config"
sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' "$ssh_config"

systemctl enable sshd
systemctl restart sshd

