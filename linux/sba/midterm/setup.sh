#!/bin/bash

# setup script for fresh RHEL 8.10 VMs for midterm sba refer to school-git/.resources/linux/SBA-midterm.md

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

print_info "Starting SBA Midterm Setup Script"
echo "================================================"

# 1. Update the system
print_info "Running dnf update..."
dnf update -y
print_status "System updated"

# 2. Create user 'lab' with password 'test'
print_info "Creating user 'lab' with password 'test'..."
if id "lab" &>/dev/null; then
    print_info "User 'lab' already exists"
else
    useradd lab
    echo "test" | passwd --stdin lab
    print_status "User 'lab' created with password 'test'"
fi

# 3. Ensure SSH is installed and enabled
print_info "Setting up SSH service..."
dnf install -y openssh-server
systemctl enable sshd
systemctl start sshd
print_status "SSH service enabled and started"

# 4. Configure SSH to allow password authentication for lab user
print_info "Configuring SSH for password authentication..."
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
if ! grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config; then
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
fi
systemctl restart sshd
print_status "SSH configured for password authentication"

# 5. Get hostname and IP configuration
print_info "Current hostname: $(hostname)"
read -p "Enter your server hostname (e.g., pull0037-SRV): " HOSTNAME
read -p "Enter your MN value: " MN

# Set hostname
hostnamectl set-hostname "$HOSTNAME"
print_status "Hostname set to: $HOSTNAME"

# 6. Configure static IP and alias interface
print_info "Configuring network interface with alias..."
read -p "Enter your primary network interface name (e.g., ens192): " INTERFACE

# Get the connection name
CONNECTION=$(nmcli -t -f NAME,DEVICE connection show | grep "$INTERFACE" | cut -d: -f1 | head -1)

if [[ -z "$CONNECTION" ]]; then
    print_error "No connection found for interface $INTERFACE"
    exit 1
fi

print_info "Using connection: $CONNECTION"

# Configure primary IP (172.16.30.MN)
print_info "Configuring primary IP 172.16.30.$MN..."
nmcli connection modify "$CONNECTION" ipv4.addresses "172.16.30.$MN/16"
nmcli connection modify "$CONNECTION" ipv4.gateway "172.16.0.1"
nmcli connection modify "$CONNECTION" ipv4.dns "172.16.0.1"
nmcli connection modify "$CONNECTION" ipv4.method manual

# Configure alias IP (172.16.32.MN)
print_info "Configuring alias IP 172.16.32.$MN..."
nmcli connection modify "$CONNECTION" +ipv4.addresses "172.16.32.$MN/16"

# Restart the connection
nmcli connection down "$CONNECTION" 2>/dev/null || true
sleep 2
nmcli connection up "$CONNECTION"
print_status "Network configured with primary IP 172.16.30.$MN and alias 172.16.32.$MN"

# 7. Configure firewall with iptables
print_info "Configuring firewall with iptables..."
# Stop and mask firewalld
systemctl stop firewalld 2>/dev/null || true
systemctl mask firewalld
print_status "Firewalld stopped and masked"

# Install iptables services
dnf install -y iptables-services

# Enable and start iptables
systemctl enable iptables
systemctl start iptables

# Clear existing rules
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

# Set default policies
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow SSH
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Save iptables rules
service iptables save
print_status "Iptables configured and rules saved"

# 8. Verify SSH access for lab user
print_info "Verifying SSH setup..."
print_status "Setup complete!"
echo ""
echo "================================================"
echo "Summary:"
echo "- System updated"
echo "- User 'lab' created with password 'test'"
echo "- Hostname: $HOSTNAME"
echo "- Primary IP: 172.16.30.$MN"
echo "- Alias IP: 172.16.32.$MN"
echo ""
echo "Test SSH access with:"
echo "  ssh lab@172.16.30.$MN"
echo ""
echo "Please reboot the system for all changes to take effect."
read -p "Reboot now? (y/n): " REBOOT
if [[ "$REBOOT" == "y" || "$REBOOT" == "Y" ]]; then
    reboot
fi
