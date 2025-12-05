#!/bin/bash
# Minor 2: Basic NFS Share
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
SHARE_DIR="/srv/nfs/share"

echo "Configuring Basic NFS Share..."

# Install NFS Utils
echo "Installing nfs-utils..."
dnf install -y nfs-utils

# Create Share Directory
echo "Creating share directory ${SHARE_DIR}..."
mkdir -p ${SHARE_DIR}
# "read/write access to any client" -> Permissions on folder need to be open
chmod 777 ${SHARE_DIR}

# Configure Exports
echo "Configuring /etc/exports..."
# "Provides read/write access to any client on the network."
# We use * but firewall restricts access.
echo "${SHARE_DIR} *(rw,sync,no_root_squash)" >/etc/exports

# Export shares
exportfs -r

# Firewall Configuration
echo "Configuring Firewall (iptables) - Appending rules..."

# Ensure iptables is running
systemctl enable --now iptables

# Allow NFS from Client Network
# NFS requires multiple ports: 2049 (TCP/UDP), 111 (TCP/UDP for rpcbind), and mountd/statd ports
# For simplicity in this lab environment, we often open the necessary ports.
# However, NFSv4 only needs 2049. If using NFSv3, we need more.
# The script installs nfs-utils.
# Let's allow standard NFS ports.

iptables -A INPUT -p tcp -s ${CLIENT_NET} --dport 2049 -j ACCEPT
iptables -A INPUT -p udp -s ${CLIENT_NET} --dport 2049 -j ACCEPT
iptables -A INPUT -p tcp -s ${CLIENT_NET} --dport 111 -j ACCEPT
iptables -A INPUT -p udp -s ${CLIENT_NET} --dport 111 -j ACCEPT

# Fix mountd port to 20048 (common convention)
if [ -f /etc/nfs.conf ]; then
    if ! grep -q "port=20048" /etc/nfs.conf; then
        echo "[mountd]" >>/etc/nfs.conf
        echo "port=20048" >>/etc/nfs.conf
    fi
fi

iptables -A INPUT -p tcp -s ${CLIENT_NET} --dport 20048 -j ACCEPT
iptables -A INPUT -p udp -s ${CLIENT_NET} --dport 20048 -j ACCEPT

# Save rules
iptables-save >/etc/sysconfig/iptables

# Start Services
echo "Starting NFS services..."
systemctl enable --now nfs-server rpcbind
systemctl restart nfs-server

echo "NFS Configuration Complete."
echo "========================================================"
echo "Client Verification Instructions:"
echo "1. mkdir -p /mnt/nfs"
echo "2. mount -t nfs 172.16.30.${MN}:${SHARE_DIR} /mnt/nfs"
echo "3. echo \"Your Name & ${MN}\" > /mnt/nfs/readme.nfs"
echo "4. cat /mnt/nfs/readme.nfs"
echo "========================================================"
