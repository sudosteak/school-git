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
MN=${1:-105}
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
echo "${SHARE_DIR} *(rw,sync,no_root_squash)" > /etc/exports

# Export shares
exportfs -r

# Firewall Configuration
echo "Configuring Firewall..."
systemctl enable --now firewalld
firewall-cmd --set-default-zone=drop
firewall-cmd --permanent --zone=public --add-source=${CLIENT_NET}
firewall-cmd --permanent --zone=public --add-service=nfs
firewall-cmd --permanent --zone=public --add-service=mountd
firewall-cmd --permanent --zone=public --add-service=rpc-bind
firewall-cmd --reload

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
