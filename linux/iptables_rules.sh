#!/bin/bash

read -p "what is your server ip " server_ip
read -p "what is your client ip " client_ip
read -p "what port do you want to use " port

# flush existing rules
echo "Flushing existing iptables rules..."
iptables -F

# adding iptables rules
echo "Adding iptables rules..."

# allow loopback interface traffic
iptables -A INPUT -i lo -j ACCEPT

# allow traffic from the server's ip address
iptables -A INPUT -s $server_ip -j ACCEPT

# block incoming traffic on tcp port $port
iptables -A INPUT -p tcp --dport $port -j REJECT

# block incoming traffic from the specific client on $port
iptables -I INPUT 3 -s $client_ip -p tcp --dport $port -j REJECT

# display final rules
echo "Final iptables rules:"
iptables -L -v -n

# exit script
echo "Script completed."