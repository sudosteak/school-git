#!/bin/bash
# lab type shit with firewalld
# create a script to install and configure openssh
# ensure the script enables key-based authentication and restricts root login
# execute the script successfully on your server/client

if [[ $EUID -ne 0 ]]; then
   echo "this script must be run as root" 
   exit 1
fi

