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
MN=${1:-48}
CLIENT_NET="172.16.31.0/24"
ADMIN_USER="adam"
ADMIN_PASS="sba"

echo "Configuring SSH Access..."

# Create ${ADMIN_USER} user if not exists
if ! id "${ADMIN_USER}" &>/dev/null; then
    useradd "${ADMIN_USER}"
    echo "${ADMIN_PASS}" | passwd --stdin "${ADMIN_USER}"
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
# This implies we should only allow ${ADMIN_USER} and root to log in via SSH.
if ! grep -q "^AllowUsers" /etc/ssh/sshd_config; then
    echo "AllowUsers ${ADMIN_USER} root" >>/etc/ssh/sshd_config
else
    sed -i "s/^AllowUsers.*/AllowUsers ${ADMIN_USER} root/" /etc/ssh/sshd_config
fi

# Generate client keys if they don't exist
if [ ! -f /root/client_keys/id_rsa ]; then
    echo "Generating client keys..."
    mkdir -p /root/client_keys
    ssh-keygen -t rsa -b 2048 -f /root/client_keys/id_rsa -N "" -q
fi

# Install public key for root
mkdir -p /root/.ssh
cat /root/client_keys/id_rsa.pub >>/root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
chmod 700 /root/.ssh

# Install public key for ${ADMIN_USER}
mkdir -p /home/${ADMIN_USER}/.ssh
cat /root/client_keys/id_rsa.pub >>/home/${ADMIN_USER}/.ssh/authorized_keys
chown -R ${ADMIN_USER}:${ADMIN_USER} /home/${ADMIN_USER}/.ssh
chmod 600 /home/${ADMIN_USER}/.ssh/authorized_keys
chmod 700 /home/${ADMIN_USER}/.ssh

# Firewall Configuration
echo "Configuring Firewall (iptables) - Appending rules..."

# Ensure iptables is running
systemctl enable --now iptables

# Allow SSH from Client Network (Check if exists first to avoid duplicates)
iptables -C INPUT -p tcp -s ${CLIENT_NET} --dport 22 -j ACCEPT 2>/dev/null ||
    iptables -A INPUT -p tcp -s ${CLIENT_NET} --dport 22 -j ACCEPT

# Save rules
iptables-save >/etc/sysconfig/iptables

# Restart SSH
systemctl restart sshd

echo "Current iptables rules:"
iptables -L -n -v

echo "SSH Configuration Complete."
echo "========================================================"
echo "IMPORTANT: Copy the private key to the client machine!"
echo "Key location: /root/client_keys/id_rsa"
echo "On Client:"
echo "  mkdir -p ~/.ssh"
echo "  vim ~/.ssh/id_rsa (Paste content of /root/client_keys/id_rsa)"
echo "  chmod 600 ~/.ssh/id_rsa"
echo "  ssh -i ~/.ssh/id_rsa ${ADMIN_USER}@172.16.30.${MN}"
echo "========================================================"
