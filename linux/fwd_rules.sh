#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "this script must be run as root"
    exit 1
fi

# define variables
service=ssh
client_ip="172.16.31.0/16"
host_ip="172.16.0.1"

# flush all existing ssh rules for these sources
firewall-cmd --permanent --remove-rich-rule="rule family=\"ipv4\" source address=\"$client_ip\" service name=\"$service\" accept" 2>/dev/null
firewall-cmd --permanent --remove-rich-rule="rule family=\"ipv4\" source address=\"$host_ip\" service name=\"$service\" accept" 2>/dev/null
firewall-cmd --permanent --remove-rich-rule="rule family=\"ipv4\" source address=\"0.0.0.0/0\" service name=\"$service\" reject" 2>/dev/null


# allow ssh from client_ip and host_ip
firewall-cmd --permanent --add-rich-rule="rule family=\"ipv4\" source address=\"$client_ip\" service name=\"$service\" accept"
firewall-cmd --permanent --add-rich-rule="rule family=\"ipv4\" source address=\"$host_ip\" service name=\"$service\" accept"

# block ssh from everyone else
firewall-cmd --permanent --add-rich-rule="rule family=\"ipv4\" source address=\"0.0.0.0/0\" service name=\"$service\" reject"

firewall-cmd --reload

# display current rules
echo "current firewall rules:"
firewall-cmd --list-all