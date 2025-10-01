#!/bin/bash

# firewalld ssh access control script
# allow ssh from subnet, deny from others

# check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "this script must be run as root" 
   exit 1
fi

# configuration
subnet=172.16.0.0/16
if1=172.16.30.48
if2=172.16.32.48

# install and setup openssh
echo "installing openssh..."
dnf install -y openssh

# enable and start sshd service
echo "enabling and starting sshd service..."
systemctl enable sshd
systemctl start sshd

# verify sshd is running
if systemctl is-active --quiet sshd; then
    echo "sshd service is active"
else
    echo "warning: sshd service failed to start"
fi

# configure sshd security settings
echo "configuring sshd security settings..."

# backup original sshd_config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# disable root login
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
if ! grep -q "^PermitRootLogin" /etc/ssh/sshd_config; then
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config
fi

# configure listen addresses
sed -i 's/^#*ListenAddress.*//' /etc/ssh/sshd_config
echo "ListenAddress $if1" >> /etc/ssh/sshd_config
echo "ListenAddress $if2" >> /etc/ssh/sshd_config

# restart sshd to apply changes
echo "restarting sshd service..."
systemctl restart sshd

# verify configuration
echo "sshd configuration applied:"
echo "  - root login: disabled"
echo "  - listen addresses: $if1, $if2"

echo "configuring firewalld for subnet: $subnet"

# start firewalld
systemctl start firewalld
systemctl enable firewalld

# set default zone to drop
firewall-cmd --set-default-zone=drop

# create trusted zone for ssh
firewall-cmd --permanent --new-zone=trusted-ssh 2>/dev/null
firewall-cmd --permanent --zone=trusted-ssh --add-service=ssh
firewall-cmd --permanent --zone=trusted-ssh --add-source=$subnet

# reload to apply changes
firewall-cmd --reload

# display configuration
echo ""
echo "active zones:"
firewall-cmd --get-active-zones
echo ""
echo "trusted-ssh zone:"
firewall-cmd --zone=trusted-ssh --list-all
