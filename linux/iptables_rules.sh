#!/bin/bash

# check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "this script must be run as root" 
   exit 1
fi

read -p "what is your server ip: " server_ip
read -p "what is your client ip: " client_ip
read -p "what port do you want to use: " port

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
iptables -A INPUT -p tcp -s 

# block traffic from all other hosts


# display final rules
echo "Final iptables rules:"
iptables -L -n --line-numbers

# exit script
echo "Script completed."