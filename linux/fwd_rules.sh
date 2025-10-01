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
