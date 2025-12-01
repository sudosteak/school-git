#!/bin/bash
# Minor 1: SSH Access
# Author: GitHub Copilot
# Date: 2025-11-28

set -euo pipefail

# Check for root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Configuration
MN=${1:-105}
CLIENT_NET="172.16.31.0/24"

echo "Configuring SSH Access..."

# Create admin user if not exists
if ! id "admin" &>/dev/null; then
    useradd admin
    echo "sba" | passwd --stdin admin
fi

# Configure SSH
echo "Configuring /etc/ssh/sshd_config..."
# Backup original
cp -n /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Ensure PubkeyAuthentication is yes
sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^PubkeyAuthentication no/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Restrict users (AllowUsers)
# "The client user cst8246 must be able to connect admin and root only"
# This implies we should only allow admin and root to log in via SSH.
if ! grep -q "^AllowUsers" /etc/ssh/sshd_config; then
    echo "AllowUsers admin root" >> /etc/ssh/sshd_config
else
    sed -i 's/^AllowUsers.*/AllowUsers admin root/' /etc/ssh/sshd_config
fi

# Setup Keys (Optional helper: Generate keys for client to use)
# Since we can't touch the client, we will generate a keypair here and print instructions
echo "Generating temporary SSH keypair for client usage..."
mkdir -p /root/client_keys
rm -f /root/client_keys/id_rsa*
ssh-keygen -t rsa -b 2048 -f /root/client_keys/id_rsa -N "" -q

# Install public key for root
mkdir -p /root/.ssh
cat /root/client_keys/id_rsa.pub >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
chmod 700 /root/.ssh

# Install public key for admin
mkdir -p /home/admin/.ssh
cat /root/client_keys/id_rsa.pub >> /home/admin/.ssh/authorized_keys
chown -R admin:admin /home/admin/.ssh
chmod 600 /home/admin/.ssh/authorized_keys
chmod 700 /home/admin/.ssh

# Firewall Configuration
echo "Configuring Firewall..."
systemctl enable --now firewalld
firewall-cmd --set-default-zone=drop
firewall-cmd --permanent --zone=public --add-source=${CLIENT_NET}
firewall-cmd --permanent --zone=public --add-service=ssh
firewall-cmd --reload

# Restart SSH
systemctl restart sshd

echo "SSH Configuration Complete."
echo "========================================================"
echo "IMPORTANT: Copy the private key to the client machine!"
echo "Key location: /root/client_keys/id_rsa"
echo "On Client:"
echo "  mkdir -p ~/.ssh"
echo "  vim ~/.ssh/id_rsa (Paste content of /root/client_keys/id_rsa)"
echo "  chmod 600 ~/.ssh/id_rsa"
echo "  ssh -i ~/.ssh/id_rsa admin@172.16.30.${MN}"
echo "========================================================"
