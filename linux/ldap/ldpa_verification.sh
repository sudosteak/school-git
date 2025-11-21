ldapsearch -x -H ldap://IP -b "dc=example48,dc=lab"
getent hosts

iptables -L -n | grep 389

iptables -I INPUT -p tcp --dport 389 -s "172.16.30.0/24" -j REJECT
iptables -I INPUT -p tcp --dport 389 -s "172.16.31.0/24" -j ACCEPT
iptables -I INPUT -p tcp --dport 389 -s "172.16.32.0/24" -j ACCEPT