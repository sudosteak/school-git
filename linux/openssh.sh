#!/bin/bash

#
# program name: openssh.sh
# program purpose: automate openssh installation and configuration on rhel 8.10
# author: Jacob P, 041156249, 010
# date & version: 03-10-2025, version: 1.0
#

if [[ $EUID -ne 0 ]]; then
    echo "this script must be run as root"
    exit 1
fi

# variables
ssh_config="/etc/ssh/sshd_config"
alias_ip="${ALIAS_IP:-}"
interface="${INTERFACE:-}"
ssh_user="${SSH_USER:-}"

# install openssh packages
echo "installing openssh packages..."
dnf install -y openssh-server openssh-clients &>/dev/null || { echo "installation failed"; exit 1; }

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

