#!/bin/bash

# variables
ssh_config="/etc/ssh/sshd_config"
server="pull0037-SRV.example48.lab"


# check if openssh is already installed
if rpm -q openssh &>/dev/null; then
    echo "openssh is already installed"
else
    echo "openssh is not installed, proceeding with installation..."
    dnf install -y openssh &>/dev/null || { echo "installation failed"; exit 1; }
fi

# checks for ssh keys
if [[ ! -f /home/cst8246/.ssh/id_rsa.pub ]]; then
    echo "generating ssh keys for cst8246"
    ssh-keygen -t rsa -b 4096 -f "/home/cst8246/.ssh/id_rsa" -N ""
else
    echo "skipping ssh key gen, keys already exist for cst8246"
fi

ssh-copy-id -f cst8246@pull0037-SRV.example48.lab


# configure ssh security with sed
#sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' "$ssh_config"
#sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' "$ssh_config"
#sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' "$ssh_config"
#sed -i 's/^#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' "$ssh_config"

echo "ssh security configured"

