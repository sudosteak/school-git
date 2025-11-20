#!/bin/bash

#
# CST8246 - OpenSSH Installation and Configuration Automation
# Jacob P, 041156249, 010
# Lab 3 - Automated SSH Setup
#

# check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "this script must be run as root" 
   exit 1
fi

# variables
ssh_config="/etc/ssh/sshd_config"
server="pull0037-SRV.example48.lab"
ssh_user="cst8246"
alias_ip="172.16.32.48"
interface="enp2s0"

echo "=== openssh installation and configuration ==="

# step 1: install openssh packages
echo ""
echo "step 1: checking openssh installation..."
if rpm -q openssh-server &>/dev/null && rpm -q openssh-clients &>/dev/null; then
    echo "openssh-server and openssh-clients are already installed"
else
    echo "installing openssh packages..."
    dnf install -y openssh-server openssh-clients || { echo "installation failed"; exit 1; }
    echo "openssh packages installed successfully"
fi

# step 2: configure alias ip
echo ""
echo "step 2: configuring alias ip..."
if ! ip addr show $interface | grep -q $alias_ip; then
    echo "adding alias ip $alias_ip to $interface..."
    nmcli connection modify $interface +ipv4.addresses $alias_ip/24
    nmcli connection up $interface
    echo "alias ip configured"
else
    echo "alias ip already configured"
fi

# step 3: configure ssh security settings
echo ""
echo "step 3: configuring ssh security..."

# backup original config
if [[ ! -f ${ssh_config}.backup ]]; then
    cp $ssh_config ${ssh_config}.backup
    echo "backup created: ${ssh_config}.backup"
fi

# disable root login
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' "$ssh_config"

# enable public key authentication
sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' "$ssh_config"

# allow password authentication (for initial setup)
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' "$ssh_config"

# disable challenge response authentication
sed -i 's/^#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' "$ssh_config"

echo "ssh security settings configured"

# step 4: generate ssh keys for user
echo ""
echo "step 4: setting up ssh keys for $ssh_user..."
if [[ ! -f /home/$ssh_user/.ssh/id_rsa.pub ]]; then
    echo "generating ssh keys for $ssh_user..."
    sudo -u $ssh_user ssh-keygen -t rsa -b 4096 -f "/home/$ssh_user/.ssh/id_rsa" -N ""
    echo "ssh keys generated"
else
    echo "ssh keys already exist for $ssh_user"
fi

# step 5: enable and start ssh service
echo ""
echo "step 5: enabling and starting ssh service..."
systemctl enable sshd
systemctl restart sshd

if systemctl is-active --quiet sshd; then
    echo "ssh service is running"
else
    echo "failed to start ssh service"
    exit 1
fi

# display ssh service status
echo ""
echo "ssh service status:"
systemctl status sshd --no-pager | grep -E "(Active|Loaded|listening)"

ssh-copy-id $ssh_user@$server

