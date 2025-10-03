#!/bin/bash

# check for root
if [[ $EUID -ne 0 ]]; then
    echo "this script must be run as root"
    exit 1
fi

# variables
ssh_config="/etc/ssh/sshd_config"
alias_ip="${ALIAS_IP:-}"
interface="${INTERFACE:-}"
ssh_user="${SSH_USER:-}"

# check if openssh is already installed
if rpm -q openssh-server &>/dev/null; then
    echo "openssh-server is already installed"
else
    echo "openssh-server is not installed, proceeding with installation..."
    dnf install -y openssh-server openssh-clients &>/dev/null || { echo "installation failed"; exit 1; }
fi

# checks for ssh keys
if [[ ! -f $HOME/.ssh/id_rsa.pub ]]; then
    echo "generating ssh keys for $USER"
    ssh-keygen -t rsa -b 4096
else
    echo "skipping ssh key gen, keys already exist for $USER"
fi

# backup existing config
cp "$ssh_config" "${ssh_config}.backup"

# configure ssh security with sed
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' "$ssh_config"
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' "$ssh_config"
sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' "$ssh_config"
sed -i 's/^#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' "$ssh_config"

echo "ssh security configured"

# enable and restart sshd
systemctl enable sshd &>/dev/null
systemctl restart sshd

if systemctl is-active --quiet sshd; then
    echo "ssh service active"
    echo "configure firewall and test connection before closing session"
else
    echo "failed to start ssh service"
    systemctl status sshd
    exit 1
fi

