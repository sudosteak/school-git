#!/bin/bash

# minor iptables script for midterm sba refer to school-git/.resources/linux/SBA-midterm.md lines 21 to 28
# Minor Service #2: Firewall / Netcat (NC)
# Set up NC listening on port 49876. Allow access from the client network and reject all other sources.
# Server: nc -vl 172.16.30.MN 49876
# Client: nc -v 172.16.30.MN 49876 → should connect
# Server → Server connection should be refused.

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

print_info "Starting Firewall/Netcat Configuration for SBA Midterm"
echo "================================================"

# Magic number
MN=48

read -p "Enter port number to use [49955]: " PORT
PORT=${PORT:-49955}

# Define variables
server="172.16.30.${MN}"
client_net="172.16.31.0/24"
server_net="172.16.30.0/24"
alias_net="172.16.32.0/24"

print_info "Server IP: ${server}"
print_info "Netcat Port: ${PORT}"
print_info "Allowed network: ${client_net}"

# Install nmap-ncat if not installed
if ! rpm -q nmap-ncat >/dev/null 2>&1; then
    print_info "Installing nmap-ncat..."
    dnf install -y nmap-ncat
fi

# Ensure iptables-services is installed
if ! rpm -q iptables-services >/dev/null 2>&1; then
    print_info "Installing iptables-services..."
    dnf install -y iptables-services
fi

print_status "Required packages installed"

# Stop and mask firewalld
print_info "Disabling firewalld..."
systemctl stop firewalld 2>/dev/null || true
systemctl mask firewalld 2>/dev/null || true
print_status "Firewalld stopped and masked"

# Enable and start iptables
systemctl enable iptables
systemctl start iptables
print_status "Iptables service enabled and started"

# Configure firewall rules for netcat
print_info "Configuring firewall rules..."

# Remove any existing rules for this port
iptables -D INPUT -p tcp --dport ${PORT} -j ACCEPT 2>/dev/null || true
iptables -D INPUT -p tcp --dport ${PORT} -j REJECT 2>/dev/null || true

# Allow connections from client network (172.16.31.0/24)
iptables -A INPUT -p tcp --dport ${PORT} -s ${client_net} -j ACCEPT

# Reject connections from server network (172.16.30.0/24) - server to server blocked
iptables -A INPUT -p tcp --dport ${PORT} -s ${server_net} -j REJECT

# Reject connections from alias network (172.16.32.0/24)
iptables -A INPUT -p tcp --dport ${PORT} -s ${alias_net} -j REJECT

# Reject all other connections to this port
iptables -A INPUT -p tcp --dport ${PORT} -j REJECT

# Save iptables rules
service iptables save
print_status "Firewall rules configured and saved"

# Display firewall rules
echo ""
echo "================================================"
echo "Active Firewall Rules for Port ${PORT}"
echo "================================================"
iptables -L INPUT -n --line-numbers | grep -E "(Chain|${PORT}|policy)" || iptables -L INPUT -n --line-numbers

echo ""
echo "================================================"
echo "Configuration Summary"
echo "================================================"
echo "Netcat Port: ${PORT}"
echo "Server IP: ${server}"
echo ""
echo "Firewall Rules:"
echo "  ✓ ACCEPT from client network: ${client_net}"
echo "  ✗ REJECT from server network: ${server_net}"
echo "  ✗ REJECT from alias network: ${alias_net}"
echo "  ✗ REJECT from all other sources"
echo ""
echo "================================================"
print_status "Firewall/Netcat Configuration Complete!"
echo "================================================"
echo ""
echo "To start netcat listener manually:"
echo "  nc -vl ${server} ${PORT}"
echo ""
echo "Testing:"
echo "  From client (172.16.31.${MN}): nc -v ${server} ${PORT}  [SHOULD CONNECT]"
echo "  From server (172.16.30.${MN}): nc -v ${server} ${PORT}  [SHOULD BE REFUSED]"
echo ""
