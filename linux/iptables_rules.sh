#!/bin/bash

# check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "this script must be run as root" 
   exit 1
fi

server_ip=172.16.30.48
client_ip=172.16.31.48
subnet=172.16.31.0/24
port=49999

# flush existing rules
echo "Flushing existing iptables rules..."
iptables -F

# adding iptables rules
echo "Adding iptables rules..."

# allow loopback interface traffic
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# block traffic from a specific client
iptables -A INPUT -p tcp -s $client_ip --dport $port -j REJECT

# allow traffic from other hosts in the client subnet
iptables -A INPUT -p tcp -s $subnet --dport $port -j ACCEPT

# block traffic from all other hosts
iptables -A INPUT -p tcp --dport $port -j REJECT

# display final rules
echo "Final iptables rules:"
iptables -L -n --line-numbers

# exit script
echo "Script completed."
