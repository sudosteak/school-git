#!/bin/bash

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "run as root"
    exit 1
fi

example_domain="example48.lab"
site_domain="site48.lab"
server="172.16.30.48"
alias="172.16.32.48"
client="172.16.31.48"
servername="pull0037-SRV.${example_domain}"

# check if running on correct server
if [[ "$(hostname -f)" != "$servername" ]]; then
    echo "testing httpd on client..."
    echo "=============================== www.${example_domain} ================================"
    dig www.${example_domain}
    curl www.${example_domain}
    echo "=============================== www.${site_domain} ================================"
    dig www.${site_domain}
    curl www.${site_domain}
    echo "=============================== secure.${example_domain} ================================"
    dig secure.${example_domain}
    curl -k https://secure.${example_domain}
    exit 1
fi

# disable SELinux
setenforce 0 || true
sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config || true

# install httpd if not installed
if ! rpm -q httpd >/dev/null 2>&1; then
    echo "installing httpd..."
    dnf install -y httpd
fi

# install openssl if not installed
if ! rpm -q openssl >/dev/null 2>&1; then
    echo "installing openssl..."
    dnf install -y openssl
fi

systemctl enable --now httpd

# create backup of httpd.conf
cp -a /etc/httpd/conf/httpd.conf{,.bak.$(date +%s)} 2>/dev/null || true

# edit servername in httpd.conf using sed
if ! grep -q "^ServerName ${servername}:80" /etc/httpd/conf/httpd.conf; then
    sed -i "/^#ServerName www.example.com:80/c\ServerName ${servername}:80" /etc/httpd/conf/httpd.conf || true
fi

# edit serverroot in httpd.conf using sed
if ! grep -q "^ServerRoot \"/etc/httpd\"" /etc/httpd/conf/httpd.conf; then
    sed -i "/^ServerRoot /c\ServerRoot \"/etc/httpd\"" /etc/httpd/conf/httpd.conf || true
fi

# change serveradmin to root@$example_domain
if ! grep -q "^ServerAdmin root@${example_domain}" /etc/httpd/conf/httpd.conf; then
    sed -i "/^ServerAdmin /c\ServerAdmin root@${example_domain}" /etc/httpd/conf/httpd.conf || true
fi

# make the directories for the lab
rm -rf /var/www/vhosts 2>/dev/null || true
mkdir -p /var/www/vhosts/www.${example_domain}/{html,logs}
mkdir -p /var/www/vhosts/secure.${example_domain}/{html,logs}
mkdir -p /var/www/vhosts/www.${site_domain}/{html,logs}

rm -rf /etc/httpd/tls 2>/dev/null || true
mkdir /etc/httpd/tls 2>/dev/null || true
mkdir /etc/httpd/tls/key 2>/dev/null || true
mkdir /etc/httpd/tls/cert 2>/dev/null || true

chmod 700 /etc/httpd/tls/key
chmod 755 /etc/httpd/tls/cert

# make certificate
yum install -y mod_ssl
openssl req -x509 -newkey rsa -days 120 -nodes \
    -keyout /etc/httpd/tls/key/example48.key \
    -out /etc/httpd/tls/cert/example48.cert \
    -subj "/O=CST8246/OU=example48.lab/CN=secure.example48.lab"
chmod 600 /etc/httpd/tls/key/example48.key
chmod 644 /etc/httpd/tls/cert/example48.cert

cat > /var/www/html/index.html <<EOF
<head><title>$servername</title></head>
<h1>host:$servername [$server:80]</h1>
EOF

cat > /var/www/vhosts/www.$example_domain/html/index.html <<EOF
<head><title>www.$example_domain</title></head>
<h1>host:www.$example_domain [$server:80]</h1>
EOF

cat > /var/www/vhosts/www.$site_domain/html/index.html <<EOF
<head><title>www.$site_domain</title></head>
<h1>host:www.$site_domain [$server:80]</h1>
EOF

cat > /var/www/vhosts/secure.$example_domain/html/index.html <<EOF
<head><title>secure.$example_domain</title></head>
<h1>host:secure.$example_domain [$alias:443]</h1>
EOF

# load the mod_ssl module if not already loaded
if ! grep -q "^LoadModule ssl_module modules/mod_ssl.so" /etc/httpd/conf.modules.d/00-ssl.conf; then
    sed -i "/^#LoadModule ssl_module modules\/mod_ssl.so/c\LoadModule ssl_module modules/mod_ssl.so" /etc/httpd/conf.modules.d/00-ssl.conf || true
fi

# backup vhosts.conf if it exists
cp -a /etc/httpd/conf.d/vhosts.conf{,.bak.$(date +%s)} 2>/dev/null || true

# create virtual host configuration
cat >/etc/httpd/conf.d/vhosts.conf <<EOF
<VirtualHost $server:80>
    ServerName www.$example_domain
    DocumentRoot /var/www/vhosts/www.$example_domain/html/
    ErrorLog /var/www/vhosts/www.$example_domain/logs/error.log
</VirtualHost>

<VirtualHost $server:80>
    ServerName www.$site_domain
    DocumentRoot /var/www/vhosts/www.$site_domain/html/
    ErrorLog /var/www/vhosts/www.$site_domain/logs/error.log
</VirtualHost>

<VirtualHost $alias:443>
    ServerName secure.$example_domain
    DocumentRoot /var/www/vhosts/secure.$example_domain/html/
    ErrorLog /var/www/vhosts/secure.$example_domain/logs/error.log

    SSLEngine on
    SSLCertificateFile /etc/httpd/tls/cert/example48.cert
    SSLCertificateKeyFile /etc/httpd/tls/key/example48.key
</VirtualHost>
EOF

# Configure iptables firewall rules
echo "Configuring iptables rules..."

# Flush existing rules (optional - comment out if you want to preserve existing rules)
# iptables -F INPUT

# Allow client network access to all HTTP ports (80 and 443)
iptables -A INPUT -p tcp -s 172.16.31.0/24 --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -s 172.16.31.0/24 --dport 443 -j ACCEPT

# Reject server network access to all HTTP ports (80 and 443)
iptables -A INPUT -p tcp -s 172.16.30.0/24 --dport 80 -j REJECT
iptables -A INPUT -p tcp -s 172.16.30.0/24 --dport 443 -j REJECT

# Reject alias network access on port 80 only
iptables -A INPUT -p tcp -s 172.16.32.0/24 --dport 80 -j REJECT

# Save iptables rules so they persist after reboot
service iptables save || echo "WARNING: could not save iptables rules"

echo "iptables rules configured successfully"

systemctl restart httpd


echo ""
echo ""
echo "testing configuration for ${HOSTNAME}..."
echo "firewall rules:"
iptables -L INPUT -v -n | grep tcp | grep dpt:80\|grep dpt:443 || true
echo ""