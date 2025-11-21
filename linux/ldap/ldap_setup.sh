cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/example48.lab
mv ldap/example48.lab/DB_CONFIG.example DB_CONFIG
mv ldap/example48.lab/DB_CONFIG.example DB_CONFIG
cd ldap/example48.lab
cp /usr/share/openldap-servers/DB_EXAMPLE.example DB_CONFIG
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
ldapadd -x -D "cn=ldapadm,dc=example48,dc=lab" -w secret -f base.ldif
ldapadd -x -D "cn=ldapadm,dc=example48,dc=lab" -w secret -f ou.ldif
ldapadd -x -D "cn=ldapadm,dc=example48,dc=lab" -w secret -f ou.ldif
ldapadd -x -D "cn=ldapadm,dc=example48,dc=lab" -w secret -f leaf.ldif
ldapadd -x -D "cn=ldapadm,dc=example48,dc=lab" -w secret -f hostsou.ldif
ldapadd -x -D "cn=ldapadm,dc=example48,dc=lab" -w secret -f ldifs/hostsou.ldif
ldapadd -x -D "cn=ldapadm,dc=example48,dc=lab" -w secret -f ldifs/hostsleaf.ldif
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
ldapmodify -x -D "cn=ldapadm,dc=example48,dc=lab" -w secret -f ldifs/email.ldif