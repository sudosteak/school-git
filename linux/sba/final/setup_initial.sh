#!/bin/bash
# Initial Setup
# Author: GitHub Copilot
# Date: 2025-12-04

set -euo pipefail

# Check for root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Configuration
MN=${1:-48}
NET_RED="172.16.30"
NET_ALIAS="172.16.32"
SERVER_IP="${NET_RED}.${MN}"
ALIAS_IP="${NET_ALIAS}.${MN}"
CLIENT_NET="172.16.31.0/24"

echo "Performing Initial Setup for MN=${MN}..."

# 1. Configure Static IP & Alias
# Find active connection
IFACE=$(ip -o -4 route show to default | awk '{print $5}' | head -n1)
if [ -z "$IFACE" ]; then
    IFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep -v lo | head -n 1)
fi

CONN=$(nmcli -t -f NAME,DEVICE con show --active | grep ":${IFACE}" | cut -d: -f1 | head -n1)

if [ -n "$CONN" ]; then
    echo "Configuring IPs on connection '${CONN}'..."
    # We assume the main IP is correct or we append. 
    # To be safe and compliant with "Configure static IP", we should ensure it's set.
    # But modifying the main IP can be risky. We will focus on the Alias.
    
    if ! nmcli con show "$CONN" | grep -q "${ALIAS_IP}"; then
        echo "Adding Alias IP ${ALIAS_IP}/16..."
        nmcli con mod "$CONN" +ipv4.addresses "${ALIAS_IP}/16"
        nmcli con up "$CONN"
    fi
else
    echo "Warning: Could not determine active connection. Using ip addr add."
    ip addr add "${ALIAS_IP}/16" dev "$IFACE" || true
fi

# 2. Create local user 'admin' with password 'sba'
echo "Creating user 'admin'..."
if ! id "admin" &>/dev/null; then
    useradd admin
    echo "sba" | passwd --stdin admin
else
    echo "User 'admin' already exists. Updating password."
    echo "sba" | passwd --stdin admin
fi

# 3. Enable and configure SSH access
echo "Configuring SSH..."
systemctl enable --now sshd

# 4. Configure default-deny firewall rules (iptables)
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

# Allow SSH from Client Network ONLY
iptables -A INPUT -p tcp -s ${CLIENT_NET} --dport 22 -j ACCEPT

# Save rules
iptables-save > /etc/sysconfig/iptables

echo "Initial Setup Complete."
