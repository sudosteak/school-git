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
echo "${SHARE_DIR} *(rw,sync,no_root_squash)" > /etc/exports

# Export shares
exportfs -r

# Firewall Configuration
echo "Configuring Firewall (iptables)..."

# Disable firewalld
systemctl disable --now firewalld

# Install iptables-services
dnf install -y iptables-services
systemctl enable --now iptables

# Flush existing rules
iptables -F
iptables -X

# Set default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT

# Allow established/related connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

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
# mountd usually runs on random ports unless configured.
# For a robust script, we should fix the ports in /etc/nfs.conf or allow all from client.
# Given the "Basic NFS Share" context, allowing all traffic from client for NFS might be safest if ports aren't fixed,
# but the requirement says "Open only the necessary ports".
# Let's try to be specific but acknowledge dynamic ports might be an issue without config.
# A common trick for lab exams is to just allow all from the trusted client IP if specific ports are hard.
# But let's stick to the requested ports in the prompt: "NFS: TCP/UDP 2049 + required rpcbind, mountd, etc."
# Since we can't easily know dynamic ports, I will add a comment and allow a range or just rely on 2049/111 if v4 is used.
# But wait, `firewall-cmd --add-service=mountd` handles this dynamically. iptables does not.
# To make this work reliably with iptables without complex scripting, we should probably fix the ports.
# Or, since this is a "Basic" setup, maybe we just allow the client full access?
# No, "Open only the necessary ports".
# I will configure /etc/nfs.conf to fix mountd port if possible, or just open a range.
# Actually, let's just open the standard ones and maybe a range for mountd if we can't fix it.
# Better yet, let's add a block to fix the ports in /etc/sysconfig/nfs or /etc/nfs.conf to make iptables rules valid.

# Fix mountd port to 20048 (common convention)
if [ -f /etc/nfs.conf ]; then
    if ! grep -q "port=20048" /etc/nfs.conf; then
        echo "[mountd]" >> /etc/nfs.conf
        echo "port=20048" >> /etc/nfs.conf
    fi
fi

iptables -A INPUT -p tcp -s ${CLIENT_NET} --dport 20048 -j ACCEPT
iptables -A INPUT -p udp -s ${CLIENT_NET} --dport 20048 -j ACCEPT

# Save rules
iptables-save > /etc/sysconfig/iptables

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
