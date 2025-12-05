#!/bin/bash
# Client Setup & Verification Script for Final SBA
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
SERVER_IP="172.16.30.${MN}"
ALIAS_IP="172.16.32.${MN}"
DOMAIN="blue.lab"
CLIENT_USER="cst8246"

echo "Starting Client Setup for Server MN=${MN}..."
echo "Server IP: ${SERVER_IP}"
echo "Alias IP:  ${ALIAS_IP}"

# ==============================================================================
# 1. DNS Slave Setup (Major 1)
# ==============================================================================
echo "----------------------------------------------------------------"
echo "Setting up DNS Slave (Major 1)..."

# Install bind
dnf install -y bind bind-utils

# Configure named.conf
echo "Configuring /etc/named.conf..."
cp -n /etc/named.conf /etc/named.conf.bak || true

cat >/etc/named.conf <<EOF
options {
    listen-on port 53 { 127.0.0.1; any; };
    listen-on-v6 port 53 { ::1; };
    directory "/var/named";
    dump-file "/var/named/data/cache_dump.db";
    statistics-file "/var/named/data/named_stats.txt";
    memstatistics-file "/var/named/data/named_mem_stats.txt";
    secroots-file "/var/named/data/named.secroots";
    recursing-file "/var/named/data/named.recursing";

    allow-query { any; };
    recursion yes;
    dnssec-enable yes;
    dnssec-validation yes;

    bindkeys-file "/etc/named.root.key";
    managed-keys-directory "/var/named/dynamic";
    pid-file "/run/named/named.pid";
    session-keyfile "/run/named/session.key";
};

logging {
    channel default_debug {
        file "data/named.run";
        severity dynamic;
    };
};

zone "." IN {
    type hint;
    file "named.ca";
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";

# Slave Zones
zone "${DOMAIN}" IN {
    type slave;
    masters { ${SERVER_IP}; };
    file "slaves/${DOMAIN}.db";
};

zone "30.16.172.in-addr.arpa" IN {
    type slave;
    masters { ${SERVER_IP}; };
    file "slaves/30.16.172.db";
};

zone "32.16.172.in-addr.arpa" IN {
    type slave;
    masters { ${SERVER_IP}; };
    file "slaves/32.16.172.db";
};
EOF

# Permissions
chown root:named /etc/named.conf
chmod 640 /etc/named.conf

# Start Service
systemctl enable --now named
systemctl restart named

# Update resolv.conf to use localhost (so we use our slave zones)
echo "Updating /etc/resolv.conf..."
echo "search ${DOMAIN}" >/etc/resolv.conf
echo "nameserver 127.0.0.1" >>/etc/resolv.conf

echo "DNS Slave Setup Complete. Verifying..."
sleep 2 # Give time for transfer
dig @127.0.0.1 www1.${DOMAIN} +short || echo "DNS Lookup Failed"

# ==============================================================================
# 2. NFS Client Setup (Minor 2)
# ==============================================================================
echo "----------------------------------------------------------------"
echo "Setting up NFS Client (Minor 2)..."

# Install utils
dnf install -y nfs-utils

# Create Mount Point
mkdir -p /mnt/nfs

# Mount
echo "Mounting NFS Share..."
mount -t nfs ${SERVER_IP}:/srv/nfs/share /mnt/nfs

# Verify Write Access
echo "Writing validation file..."
echo "Client User & MN=${MN}" >/mnt/nfs/readme.nfs

if [ -f /mnt/nfs/readme.nfs ]; then
    echo "NFS Write Successful."
    cat /mnt/nfs/readme.nfs
else
    echo "Error: NFS Write Failed."
fi

# ==============================================================================
# 3. SSH Client Setup (Minor 1)
# ==============================================================================
echo "----------------------------------------------------------------"
echo "Setting up SSH Client User (Minor 1)..."

# Create user cst8246
if ! id "${CLIENT_USER}" &>/dev/null; then
    useradd ${CLIENT_USER}
    echo "password" | passwd --stdin ${CLIENT_USER}
    echo "User ${CLIENT_USER} created."
fi

# Setup SSH directory
USER_HOME="/home/${CLIENT_USER}"
mkdir -p ${USER_HOME}/.ssh
chmod 700 ${USER_HOME}/.ssh
chown ${CLIENT_USER}:${CLIENT_USER} ${USER_HOME}/.ssh

echo "IMPORTANT: You must manually copy the private key from the server."
echo "1. On Server: cat /root/client_keys/id_rsa"
echo "2. On Client: vim ${USER_HOME}/.ssh/id_rsa (Paste content)"
echo "3. On Client: chmod 600 ${USER_HOME}/.ssh/id_rsa"
echo "4. On Client: chown ${CLIENT_USER}:${CLIENT_USER} ${USER_HOME}/.ssh/id_rsa"

# ==============================================================================
# 4. Web Verification (Major 2)
# ==============================================================================
echo "----------------------------------------------------------------"
echo "Verifying Web Hosting (Major 2)..."

echo "Checking http://www1.${DOMAIN}..."
curl -s http://www1.${DOMAIN} | grep "MN" || echo "Failed"

echo "Checking http://www2.${DOMAIN}..."
curl -s http://www2.${DOMAIN} | grep "MN" || echo "Failed"

echo "Checking https://secure.${DOMAIN}..."
curl -k -s https://secure.${DOMAIN} | grep "MN" || echo "Failed"

echo "----------------------------------------------------------------"
echo "Client Setup Script Complete."
