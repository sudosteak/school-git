#!/bin/bash
# Major 2: Advanced Web Hosting
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

NET_BLUE="172.16.31"
NET_ALIAS="172.16.32"

ALIAS_IP="${NET_ALIAS}.${MN}"
CLIENT_NET="${NET_BLUE}.0/24"

echo "Configuring Advanced Web Hosting on MN=${MN}..."

# Ensure Alias IP is up (Reuse logic from major1)
IFACE="enp2s0"
CONN=$(nmcli -t -f NAME,DEVICE con show --active | grep ":${IFACE}" | cut -d: -f1 | head -n1)
if [ -n "$CONN" ]; then
    if ! nmcli con show "$CONN" | grep -q "${ALIAS_IP}"; then
        nmcli con mod "$CONN" +ipv4.addresses "${ALIAS_IP}/16"
        nmcli con up "$CONN"
    fi
else
    ip addr add "${ALIAS_IP}/16" dev "$IFACE" || true
fi

# Install Apache and SSL
echo "Installing httpd and mod_ssl..."
dnf install -y httpd mod_ssl

# Create Document Roots
mkdir -p /var/www/html/www1
mkdir -p /var/www/html/www2
mkdir -p /var/www/html/secure

# Create Content
echo "MN: ${MN} - Domain: www1.blue.lab" >/var/www/html/www1/index.html
echo "MN: ${MN} - Domain: www2.blue.lab" >/var/www/html/www2/index.html
echo "MN: ${MN} - Domain: secure.blue.lab" >/var/www/html/secure/index.html

# Generate Self-Signed Certificate for secure.blue.lab
echo "Generating SSL Certificate..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/pki/tls/private/secure.blue.lab.key \
    -out /etc/pki/tls/certs/secure.blue.lab.crt \
    -subj "/C=CA/ST=Ontario/L=Ottawa/O=BlueLab/CN=secure.blue.lab"

# Configure Virtual Hosts
echo "Configuring Virtual Hosts..."
cat >/etc/httpd/conf.d/vhosts.conf <<EOF
<VirtualHost *:80>
    ServerName www1.blue.lab
    DocumentRoot /var/www/html/www1
    <Directory /var/www/html/www1>
        AllowOverride None
        Require all granted
    </Directory>
</VirtualHost>

<VirtualHost *:80>
    ServerName www2.blue.lab
    DocumentRoot /var/www/html/www2
    <Directory /var/www/html/www2>
        AllowOverride None
        Require all granted
    </Directory>
</VirtualHost>

<VirtualHost ${ALIAS_IP}:443>
    ServerName secure.blue.lab
    DocumentRoot /var/www/html/secure
    SSLEngine on
    SSLCertificateFile /etc/pki/tls/certs/secure.blue.lab.crt
    SSLCertificateKeyFile /etc/pki/tls/private/secure.blue.lab.key
    <Directory /var/www/html/secure>
        AllowOverride None
        Require all granted
    </Directory>
</VirtualHost>
EOF

# Firewall Configuration
echo "Configuring Firewall (iptables) - Appending rules..."

# Ensure iptables is running
systemctl enable --now iptables

# Allow HTTP/HTTPS from Client Network
iptables -A INPUT -p tcp -s ${CLIENT_NET} --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -s ${CLIENT_NET} --dport 443 -j ACCEPT

# Save rules
iptables-save >/etc/sysconfig/iptables

# Start Service
echo "Starting httpd..."
systemctl enable --now httpd
systemctl restart httpd

echo "Advanced Web Hosting Configuration Complete."
