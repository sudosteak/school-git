#!/bin/bash

# major dns script for midterm sba refer to school-git/.resources/linux/SBA-midterm.md lines 54 to 60
# Configure DNS: Set up ns1.happy.lab with forward zone on server (172.16.30.MN)
# Allow queries from client and server networks
# Verify: dig ns1.happy.lab

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[i]${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run as root"
   exit 1
fi

print_info "Starting DNS Configuration for SBA Midterm"
echo "================================================"

# Magic number
MN=48

# Define variables
domain="happy.lab"
server="172.16.30.${MN}"
client="172.16.31.${MN}"
alias="172.16.32.${MN}"
net="172.16.0.0/16"
client_net="172.16.31.0/24"
server_net="172.16.30.0/24"
rev="16.172.in-addr.arpa"

print_info "Domain: ${domain}"
print_info "Server IP: ${server}"
print_info "Client IP: ${client}"

# Install bind and bind-utils if not installed
if ! rpm -q bind bind-utils >/dev/null 2>&1; then
    print_info "Installing bind and bind-utils..."
    dnf install -y bind bind-utils
fi

# Ensure iptables-services is installed
if ! rpm -q iptables-services >/dev/null 2>&1; then
    print_info "Installing iptables-services..."
    dnf install -y iptables-services
fi

print_status "Required packages installed"

# Backup existing named.conf
if [[ -f /etc/named.conf ]]; then
    cp -a /etc/named.conf{,.bak.$(date +%s)}
    print_status "Backed up existing named.conf"
fi

# Create named.conf for master server
print_info "Configuring /etc/named.conf..."
cat >/etc/named.conf <<EOF
options {
    listen-on port 53 { 127.0.0.1; ${server}; };
    listen-on-v6 port 53 { ::1; };
    directory "/var/named";
    dump-file "/var/named/data/cache_dump.db";
    statistics-file "/var/named/data/named_stats.txt";
    memstatistics-file "/var/named/data/named_mem_stats.txt";
    secroots-file "/var/named/data/named.secroots";
    recursing-file "/var/named/data/named.recursing";
    allow-query { localhost; ${server_net}; ${client_net}; };
    allow-recursion { ${server_net}; ${client_net}; };

    recursion yes;

    dnssec-enable yes;
    dnssec-validation yes;

    managed-keys-directory "/var/named/dynamic";

    pid-file "/run/named/named.pid";
    session-keyfile "/run/named/session.key";

    include "/etc/crypto-policies/back-ends/bind.config";
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

zone "${domain}" IN {
    type master;
    file "fwd.${domain}";
    allow-update { none; };
};

zone "${rev}" IN {
    type master;
    file "rvs.${domain}";
    allow-update { none; };
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
EOF

print_status "Created /etc/named.conf"

# Create forward zone file
print_info "Creating forward zone file..."
cat >/var/named/fwd.${domain} <<EOF
\$TTL 86400
@   IN  SOA ns1.${domain}. dnsadmin.${domain}. (
                    $(date +%Y%m%d01) ; serial
                    1D      ; refresh
                    1H      ; retry
                    1W      ; expire
                    3H )    ; minimum
@   IN  NS  ns1.${domain}.
ns1 IN  A   ${server}
EOF

print_status "Created forward zone file"

# Create reverse zone file
print_info "Creating reverse zone file..."
cat >/var/named/rvs.${domain} <<EOF
\$TTL 1D
@   IN  SOA ns1.${domain}. dnsadmin.${domain}. (
                    $(date +%Y%m%d01) ; serial
                    1D      ; refresh
                    1H      ; retry
                    1W      ; expire
                    3H )    ; minimum
@   IN  NS  ns1.${domain}.

${MN}.30   IN  PTR ns1.${domain}.
EOF

print_status "Created reverse zone file"

# Set proper permissions
chown root:named /var/named/fwd.${domain} /var/named/rvs.${domain}
chmod 640 /var/named/fwd.${domain} /var/named/rvs.${domain}
print_status "Set permissions on zone files"

# Validate zone files
print_info "Validating zone files..."
if named-checkzone ${domain} /var/named/fwd.${domain}; then
    print_status "Forward zone validation passed"
else
    print_error "Forward zone validation failed"
    exit 1
fi

if named-checkzone ${rev} /var/named/rvs.${domain}; then
    print_status "Reverse zone validation passed"
else
    print_error "Reverse zone validation failed"
    exit 1
fi

# Validate named.conf
print_info "Validating named.conf..."
if /usr/sbin/named-checkconf /etc/named.conf; then
    print_status "named.conf validation passed"
else
    print_error "named.conf validation failed"
    exit 1
fi

# Configure firewall with iptables
print_info "Configuring firewall rules..."

# Ensure firewalld is stopped
systemctl stop firewalld 2>/dev/null || true
systemctl mask firewalld 2>/dev/null || true

# Enable iptables
systemctl enable iptables
systemctl start iptables

# Clear INPUT chain for DNS
iptables -D INPUT -p udp --dport 53 -j ACCEPT 2>/dev/null || true
iptables -D INPUT -p tcp --dport 53 -j ACCEPT 2>/dev/null || true

# Allow DNS queries from client network (172.16.31.0/24)
iptables -I INPUT -p udp --dport 53 -s ${client_net} -j ACCEPT
iptables -I INPUT -p tcp --dport 53 -s ${client_net} -j ACCEPT

# Allow DNS queries from server network (172.16.30.0/24)
iptables -I INPUT -p udp --dport 53 -s ${server_net} -j ACCEPT
iptables -I INPUT -p tcp --dport 53 -s ${server_net} -j ACCEPT

# Save iptables rules
service iptables save
print_status "Firewall rules configured and saved"

# Configure resolv.conf
print_info "Configuring /etc/resolv.conf..."
cat >/etc/resolv.conf <<EOF
search ${domain}
nameserver ${server}
EOF
print_status "Configured /etc/resolv.conf"

# Enable and start named service
print_info "Starting named service..."
systemctl enable named
systemctl restart named

if systemctl is-active --quiet named; then
    print_status "named service is running"
else
    print_error "named service failed to start"
    journalctl -xeu named | tail -20
    exit 1
fi

# Display configuration summary
echo ""
echo "================================================"
echo "DNS Configuration Summary"
echo "================================================"
echo "Domain: ${domain}"
echo "Name Server: ns1.${domain} (${server})"
echo "Allowed query sources:"
echo "  - Client network: ${client_net}"
echo "  - Server network: ${server_net}"
echo ""

# Show listening ports
print_info "DNS service listening on:"
netstat -tulpn | grep :53 || ss -tulpn | grep :53

echo ""
print_info "Active firewall rules for DNS:"
iptables -L INPUT -n --line-numbers | grep -E "(Chain|53)"

# Test DNS resolution
echo ""
echo "================================================"
echo "Testing DNS Resolution"
echo "================================================"

sleep 2  # Give DNS a moment to fully start

print_info "Testing forward lookup for ns1.${domain}..."
if dig @${server} ns1.${domain} +short | grep -q "${server}"; then
    print_status "Forward lookup successful: ns1.${domain} → ${server}"
else
    print_error "Forward lookup failed"
fi

print_info "Testing reverse lookup for ${server}..."
if dig @${server} -x ${server} +short | grep -q "ns1.${domain}"; then
    print_status "Reverse lookup successful: ${server} → ns1.${domain}"
else
    print_error "Reverse lookup failed"
fi

echo ""
echo "================================================"
print_status "DNS Configuration Complete!"
echo "================================================"
echo ""
echo "Verification commands:"
echo "  From server: dig ns1.${domain}"
echo "  From server: dig -x ${server}"
echo "  From client: dig @${server} ns1.${domain}"
echo ""