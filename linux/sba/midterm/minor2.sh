#!/bin/bash

# minor ssh script for midterm sba refer to school-git/.resources/linux/SBA-midterm.md lines 13 to 20
# Minor Service #1: SSH
# Set up user access to your server with both password and PublicKey authentication.
# - Password access when ssh lab@172.16.30.MN
# - PublicKey access when ssh foo@172.16.30.MN
# - Ensure both authentication methods are functional.

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

print_info "Starting SSH Configuration for SBA Midterm"
echo "================================================"

# Magic number
MN=48

server="172.16.30.${MN}"
print_info "Server IP: ${server}"

# Install openssh-server if not installed
if ! rpm -q openssh-server >/dev/null 2>&1; then
    print_info "Installing openssh-server..."
    dnf install -y openssh-server
fi
print_status "OpenSSH server installed"

# Backup existing sshd_config
if [[ -f /etc/ssh/sshd_config ]]; then
    cp -a /etc/ssh/sshd_config{,.bak.$(date +%s)}
    print_status "Backed up existing sshd_config"
fi

# Configure SSH for both password and public key authentication
print_info "Configuring /etc/ssh/sshd_config..."

# Enable password authentication
if grep -q "^PasswordAuthentication" /etc/ssh/sshd_config; then
    sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
else
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
fi

# Enable public key authentication
if grep -q "^PubkeyAuthentication" /etc/ssh/sshd_config; then
    sed -i 's/^PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
else
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
fi

# Ensure AuthorizedKeysFile is set correctly
if grep -q "^AuthorizedKeysFile" /etc/ssh/sshd_config; then
    sed -i 's|^AuthorizedKeysFile.*|AuthorizedKeysFile .ssh/authorized_keys|' /etc/ssh/sshd_config
else
    echo "AuthorizedKeysFile .ssh/authorized_keys" >> /etc/ssh/sshd_config
fi

print_status "SSH configuration updated"

# Get lab user configuration
read -p "Enter password authentication username [lab]: " LAB_USER
LAB_USER=${LAB_USER:-lab}
read -p "Enter password for user $LAB_USER [test]: " LAB_PASS
LAB_PASS=${LAB_PASS:-test}

# Ensure user exists (may have been created in setup.sh)
if ! id "$LAB_USER" &>/dev/null; then
    print_info "Creating user '$LAB_USER'..."
    useradd "$LAB_USER"
    echo "$LAB_PASS" | passwd --stdin "$LAB_USER"
    print_status "User '$LAB_USER' created with password '$LAB_PASS'"
else
    print_status "User '$LAB_USER' already exists"
    # Update password to ensure it matches
    echo "$LAB_PASS" | passwd --stdin "$LAB_USER"
    print_status "Password for user '$LAB_USER' set to '$LAB_PASS'"
fi

# Create user 'foo' for public key authentication
if ! id foo &>/dev/null; then
    print_info "Creating user 'foo'..."
    useradd foo
    print_status "User 'foo' created"
else
    print_status "User 'foo' already exists"
fi

# Setup SSH directory and authorized_keys for user 'foo'
print_info "Setting up SSH public key authentication for user 'foo'..."

# Create .ssh directory for foo
if [[ ! -d /home/foo/.ssh ]]; then
    mkdir -p /home/foo/.ssh
    chmod 700 /home/foo/.ssh
    chown foo:foo /home/foo/.ssh
fi

# Generate SSH key pair if not exists
if [[ ! -f /home/foo/.ssh/id_rsa ]]; then
    print_info "Generating SSH key pair for user 'foo'..."
    sudo -u foo ssh-keygen -t rsa -b 2048 -f /home/foo/.ssh/id_rsa -N "" -C "foo@${HOSTNAME}"
    print_status "SSH key pair generated"
fi

# Add public key to authorized_keys
if [[ -f /home/foo/.ssh/id_rsa.pub ]]; then
    cat /home/foo/.ssh/id_rsa.pub > /home/foo/.ssh/authorized_keys
    chmod 600 /home/foo/.ssh/authorized_keys
    chown foo:foo /home/foo/.ssh/authorized_keys
    print_status "Public key added to authorized_keys"
fi

# Display the private key for client setup
echo ""
print_info "Private key for user 'foo' (save this on client machine):"
echo "------------------------------------------------"
cat /home/foo/.ssh/id_rsa
echo "------------------------------------------------"
echo ""

# Also save the key to a file for easy transfer
cp /home/foo/.ssh/id_rsa /root/foo_private_key
chmod 600 /root/foo_private_key
print_status "Private key also saved to /root/foo_private_key"

# Configure firewall to allow SSH
print_info "Configuring firewall for SSH..."

# Ensure SSH is allowed in iptables (setup.sh should have already configured this)
if ! iptables -C INPUT -p tcp --dport 22 -j ACCEPT 2>/dev/null; then
    iptables -I INPUT -p tcp --dport 22 -j ACCEPT
    service iptables save
    print_status "Firewall configured (iptables)"
else
    print_status "SSH already allowed in firewall"
fi

# Enable and restart SSH service
print_info "Restarting SSH service..."
systemctl enable sshd
systemctl restart sshd

if systemctl is-active --quiet sshd; then
    print_status "SSH service is running"
else
    print_error "SSH service failed to start"
    journalctl -xeu sshd | tail -20
    exit 1
fi

# Verify SSH is listening
echo ""
print_info "SSH service status:"
netstat -tulpn | grep :22 || ss -tulpn | grep :22

# Display configuration summary
echo ""
echo "================================================"
echo "SSH Configuration Summary"
echo "================================================"
echo "Server IP: ${server}"
echo ""
echo "User '${LAB_USER}' (Password Authentication):"
echo "  Username: ${LAB_USER}"
echo "  Password: ${LAB_PASS}"
echo "  Command: ssh ${LAB_USER}@${server}"
echo ""
echo "User 'foo' (PublicKey Authentication):"
echo "  Username: foo"
echo "  Private key location on server: /root/foo_private_key"
echo "  Command (from client): ssh -i /path/to/foo_private_key foo@${server}"
echo ""
echo "SSH Configuration:"
echo "  PasswordAuthentication: yes"
echo "  PubkeyAuthentication: yes"
echo ""
echo "================================================"
print_status "SSH Configuration Complete!"
echo "================================================"
echo ""
echo "Testing from this server (localhost):"
echo "  1. Password auth: ssh ${LAB_USER}@localhost"
echo "  2. PublicKey auth: ssh -i /home/foo/.ssh/id_rsa foo@localhost"
echo ""
echo "Setup on client machine:"
echo "  1. Copy /root/foo_private_key to client"
echo "  2. On client: chmod 600 foo_private_key"
echo "  3. On client: ssh -i foo_private_key foo@${server}"
echo ""
echo "To copy the private key to client, run on client:"
echo "  scp root@${server}:/root/foo_private_key ~/"
echo ""