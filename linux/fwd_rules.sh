#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "this script must be run as root"
    exit 1
fi


#flush all existing rules
firewall-cmd --permanent --remove

service=ssh
accept_ip="172.16.31.0/16"
deny_ip="172.16.32.0/16"

# allow
firewall-cmd --permanent --zone=public --add-service=$service --source=$accept_ip

# block (remove the service for that source)
firewall-cmd --permanent --zone=public --remove-service=$service --source=$deny_ip

firewall-cmd --reload