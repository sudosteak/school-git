#!/bin/bash

#
# CST8246 - Firewall rules for SSH
# Jacob P, 041156249, 010
# Lab 3 - SSH and Firewall Configuration
#

# check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "this script must be run as root" 
   exit 1
fi

# variables
client_subnet="172.16.31.0/16"
alias_subnet="172.16.30.0/16"
ssh_port=22

# flush iptables to start with a clean slate
echo "flushing existing iptables rules..."
iptables -F

# set the default policy to be permissive
echo "setting default policies to ACCEPT..."
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# allow loopback interface traffic
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# ssh rule: accept incoming ssh traffic for subnet users (172.16.31.0/16)
echo "adding ssh rule: accept from client subnet..."
iptables -A INPUT -p tcp -s $client_subnet --dport $ssh_port -j ACCEPT

# ssh rule: deny incoming ssh traffic from all other users
echo "adding ssh rule: deny from all other sources..."
iptables -A INPUT -p tcp --dport $ssh_port -j REJECT

# other rules: deny incoming traffic from server subnet
echo "adding rule: deny from server subnet..."
iptables -A INPUT -s $server_subnet -j REJECT

# display final rules
echo ""
echo "final iptables rules:"
iptables -L -n --line-numbers

echo ""
echo "firewall configuration completed."
