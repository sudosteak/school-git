#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "this script must be run as root"
    exit 1
fi

# define variables
service=ssh
accept_ip="172.16.31.0/16"
deny_ip="172.16.32.0/16"
host_ip="172.16.0.1/16"

# flush all existing ssh rules for these sources
firewall-cmd --permanent --zone=public --remove-rich-rule="rule family=\"ipv4\" source address=\"$accept_ip\" service name=\"$service\" accept" 2>/dev/null
firewall-cmd --permanent --zone=public --remove-rich-rule="rule family=\"ipv4\" source address=\"$deny_ip\" service name=\"$service\" reject" 2>/dev/null

# allow ssh from accept_ip
firewall-cmd --permanent --zone=public --add-rich-rule="rule family=\"ipv4\" source address=\"$accept_ip\" service name=\"$service\" accept"

# block ssh from deny_ip
firewall-cmd --permanent --zone=public --add-rich-rule="rule family=\"ipv4\" source address=\"$deny_ip\" service name=\"$service\" reject"

# accept ssh from host pc
firewall-cmd --permanent --zone=public --add-rich-rule="rule family=\"ipv4\" source address=\"$host_ip\" service name=\"$service\" accept"  

firewall-cmd --reload

# display current rules
echo "current firewall rules:"
firewall-cmd --list-all