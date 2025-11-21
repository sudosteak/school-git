#!/bin/bash

set -euo pipefail
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# copy DBCONFIG.example to /var/lib/ldap and set ownership to ldap user
mkdir /var/lib/ldap/example48.lab
cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/example48.lab/DB_CONFIG
chown -R ldap /var/lib/ldap/*
cp /etc/openldap/slapd.conf /etc/openldap/slapd.conf$(date +%s).bak

# copy slapd.conf from school-git
cat /home/root/school-git/linux/ldap/srv/slapd.conf > /etc/openldap/slapd.conf
chown ldap:ldap /etc/openldap/slapd.conf

# copy ldap.conf from school-git
cat /home/root/school-git/linux/ldap/srv/ldap.conf > /etc/openldap/ldap.conf
chown ldap:ldap /etc/openldap/ldap.conf

# copy nscld.conf from school-git
cat /home/root/school-git/linux/ldap/srv/nslcd.conf > /etc/nslcd.conf

# copy nsswitch.conf from school-git
cat /home/root/school-git/linux/ldap/srv/nsswitch.conf > /etc/nsswitch.conf

# create ldifs directory and copy ldif files from school-git
mkdir /etc/openldap/ldifs
wd=$(pwd)
cd /etc/openldap/ldifs
cat /home/root/school-git/linux/ldap/srv/base.ldif > base.ldif
cat /home/root/school-git/linux/ldap/srv/ou.ldif > ou.ldif
cat /home/root/school-git/linux/ldap/srv/leaf.ldif > leaf.ldif
cat /home/root/school-git/linux/ldap/srv/hostsou.ldif > hostsou.ldif
cat /home/root/school-git/linux/ldap/srv/hostsleaf.ldif > hostsleaf.ldif
cat /home/root/school-git/linux/ldap/srv/email.ldif > email.ldif
ldapadd -x -D "cn=ldapadm,dc=example48,dc=lab" -w secret -f base.ldif
ldapadd -x -D "cn=ldapadm,dc=example48,dc=lab" -w secret -f ou.ldif
ldapadd -x -D "cn=ldapadm,dc=example48,dc=lab" -w secret -f ou.ldif
ldapadd -x -D "cn=ldapadm,dc=example48,dc=lab" -w secret -f leaf.ldif
ldapadd -x -D "cn=ldapadm,dc=example48,dc=lab" -w secret -f hostsou.ldif
ldapadd -x -D "cn=ldapadm,dc=example48,dc=lab" -w secret -f hostsleaf.ldif
ldapadd -x -D "cn=ldapadm,dc=example48,dc=lab" -w secret -f email.ldif
cd "$wd"

# enable and start nslcd and slapd services
systemctl enable --now nslcd slapd




"""
mv DB_CONFIG ldap/example48.lab/DB_CONFIG
cd /usr/share/openldap-servers
cp DB_CONFIG.example ~/ldap/example48.lab/DB_CONFIG
chown ldap:ldap DB_CONFIG
chown ldap:ldap /var/lib/ldap/*
cd /etc/openldap
mv slapd.d slap.d.bak
slaptest -u
systemctl enable --now slapd
cd /etc/openldap/ldifs
ldapsearch -x "objectClass=ipHost"
netstat -antup | grep -i 389
ping happy.example48.lab
systemctl restart NetworkManager named
ping happy.example48.lab
getent hosts
getent passwd
systemctl status nscd.service
systemctl stop nscd.service
ping happy.example48.lab
ping peachy.example48.lab
"""