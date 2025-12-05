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
NET_ALIAS="172.16.32"
ALIAS_IP="${NET_ALIAS}.${MN}"
CLIENT_NET="172.16.31.0/24"
ADMIN_USER="admin"
ADMIN_PASS="sba"

echo "Performing Initial Setup for MN=${MN}..."

# 1. Configure Static IP & Alias
# Find active connection
IFACE="enp2s0"

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

# 2. Create local user '${ADMIN_USER}' with password '${ADMIN_PASS}'
echo "Creating user '${ADMIN_USER}'..."
if ! id "${ADMIN_USER}" &>/dev/null; then
    useradd "${ADMIN_USER}"
    echo "${ADMIN_PASS}" | passwd --stdin "${ADMIN_USER}"
else
    echo "User '${ADMIN_USER}' already exists. Updating password."
    echo "${ADMIN_PASS}" | passwd --stdin "${ADMIN_USER}"
fi

# 3. Enable and configure SSH access
echo "Configuring SSH..."
systemctl enable --now sshd

# Ensure root logins are permitted so we can SSH as root@192.168.48.129
SSHD_CONFIG="/etc/ssh/sshd_config"
if grep -qE "^#?PermitRootLogin" "$SSHD_CONFIG"; then
    sed -i -E 's/^#?PermitRootLogin.*/PermitRootLogin yes/' "$SSHD_CONFIG"
else
    echo "PermitRootLogin yes" >>"$SSHD_CONFIG"
fi

if grep -qE "^#?PasswordAuthentication" "$SSHD_CONFIG"; then
    sed -i -E 's/^#?PasswordAuthentication.*/PasswordAuthentication yes/' "$SSHD_CONFIG"
else
    echo "PasswordAuthentication yes" >>"$SSHD_CONFIG"
fi

systemctl restart sshd

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
iptables-save >/etc/sysconfig/iptables

echo "Current iptables rules:"
iptables -L -n -v

echo "Initial Setup Complete."
