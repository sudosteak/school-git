#!/bin/bash
# Major 1: Master/Slave DNS
# Author: GitHub Copilot
# Date: 2025-11-28

set -euo pipefail

# Check for root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

# Configuration
MN=${1:-48} # Default MN to 48 if not provided
DOMAIN="blue.lab"
NET_RED="172.16.30"
NET_BLUE="172.16.31"
NET_ALIAS="172.16.32"
SERVER_IP="${NET_RED}.${MN}"
ALIAS_IP="${NET_ALIAS}.${MN}"
CLIENT_IP="${NET_BLUE}.${MN}"
CLIENT_NET="${NET_BLUE}.0/24"

echo "Configuring Master DNS for ${DOMAIN} on ${SERVER_IP} (MN=${MN})..."

# Network Alias Setup
# Find active connection and interface
IFACE="enp2s0"

CONN=$(nmcli -t -f NAME,DEVICE con show --active | grep ":${IFACE}" | cut -d: -f1 | head -n1)

if [ -n "$CONN" ]; then
    echo "Configuring Alias IP ${ALIAS_IP} on connection '${CONN}'..."
    # Check if IP exists in config (not just runtime)
    if ! nmcli con show "$CONN" | grep -q "${ALIAS_IP}"; then
        nmcli con mod "$CONN" +ipv4.addresses "${ALIAS_IP}/16"
        # We don't want to disrupt connection if possible, but IP add needs up
        # ip addr add ${ALIAS_IP}/16 dev ${IFACE} || true # Temporary add to avoid full restart drop
        nmcli con up "$CONN"
    fi
else
    echo "Warning: Could not determine active connection. Skipping Alias IP setup via nmcli."
    # Try ip addr add as fallback
    ip addr add "${ALIAS_IP}/16" dev "$IFACE" || true
fi

# Install packages
echo "Installing bind and bind-utils..."
dnf install -y bind bind-utils

# Configure named.conf
echo "Configuring /etc/named.conf..."
cat >/etc/named.conf <<EOF
options {
    listen-on port 53 { 127.0.0.1; ${SERVER_IP}; ${ALIAS_IP}; };
    listen-on-v6 port 53 { ::1; };
    directory "/var/named";
    dump-file "/var/named/data/cache_dump.db";
    statistics-file "/var/named/data/named_stats.txt";
    memstatistics-file "/var/named/data/named_mem_stats.txt";
    secroots-file "/var/named/data/named.secroots";
    recursing-file "/var/named/data/named.recursing";

    allow-query { localhost; ${CLIENT_NET}; };
    allow-transfer { localhost; ${CLIENT_IP}; };

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

zone "${DOMAIN}" IN {
    type master;
    file "${DOMAIN}.db";
    allow-update { none; };
};

zone "30.16.172.in-addr.arpa" IN {
    type master;
    file "30.16.172.db";
    allow-update { none; };
};

zone "32.16.172.in-addr.arpa" IN {
    type master;
    file "32.16.172.db";
    allow-update { none; };
};
EOF

# Create Zone Files
echo "Creating zone files..."

# Forward Zone
cat >/var/named/${DOMAIN}.db <<EOF
\$TTL 1D
@       IN SOA  dns1.${DOMAIN}. root.${DOMAIN}. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      dns1.${DOMAIN}.
        NS      dns2.${DOMAIN}.
        MX  10  mail.${DOMAIN}.

dns1    A       ${SERVER_IP}
dns2    A       ${ALIAS_IP}
www1    A       ${SERVER_IP}
www2    A       ${SERVER_IP}
mail    A       ${SERVER_IP}
secure  A       ${ALIAS_IP}
EOF

# Reverse Zone 30
cat >/var/named/30.16.172.db <<EOF
\$TTL 1D
@       IN SOA  dns1.${DOMAIN}. root.${DOMAIN}. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      dns1.${DOMAIN}.
        NS      dns2.${DOMAIN}.

${MN}      PTR     dns1.${DOMAIN}.
${MN}      PTR     www1.${DOMAIN}.
${MN}      PTR     www2.${DOMAIN}.105
${MN}      PTR     mail.${DOMAIN}.
EOF

# Reverse Zone 32
cat >/var/named/32.16.172.db <<EOF
\$TTL 1D
@       IN SOA  dns1.${DOMAIN}. root.${DOMAIN}. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      dns1.${DOMAIN}.
        NS      dns2.${DOMAIN}.

${MN}      PTR     dns2.${DOMAIN}.
${MN}      PTR     secure.${DOMAIN}.
EOF

# Set permissions
chown root:named /etc/named.conf
chown root:named /var/named/${DOMAIN}.db
chown root:named /var/named/30.16.172.db
chown root:named /var/named/32.16.172.db
chmod 640 /var/named/${DOMAIN}.db
chmod 640 /var/named/30.16.172.db
chmod 640 /var/named/32.16.172.db

# Firewall Configuration
echo "Configuring Firewall (iptables) - Appending rules..."

# Ensure iptables is running
systemctl enable --now iptables

# Allow DNS from Client Network
iptables -A INPUT -p udp -s ${CLIENT_NET} --dport 53 -j ACCEPT
iptables -A INPUT -p tcp -s ${CLIENT_NET} --dport 53 -j ACCEPT

# Save rules
iptables-save >/etc/sysconfig/iptables

# Start Service
echo "Starting named service..."
systemctl enable --now named
systemctl restart named

echo "Current iptables rules:"
iptables -L -n -v

echo "DNS Master Configuration Complete."
echo "========================================================"
echo "Client Configuration Instructions (Run on Client ${CLIENT_IP}):"
echo "1. Edit /etc/named.conf on client to be a slave:"
echo "   zone \"${DOMAIN}\" IN {"
echo "       type slave;"
echo "       masters { ${SERVER_IP}; };"
echo "       file \"slaves/${DOMAIN}.db\";"
echo "   };"
echo "   (Repeat for reverse zones)"
echo "2. Verify:"
echo "   dig @${SERVER_IP} ${DOMAIN} AXFR"
echo "   dig @${SERVER_IP} www1.${DOMAIN}"
echo "   dig @${SERVER_IP} -x ${SERVER_IP}"
echo "========================================================"
