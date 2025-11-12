#!/bin/bash

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "run as root"
    exit 1
fi

if [[ $HOSTNAME = "pull0037-clt.example48.lab" ]]; then
    echo "This is a client machine. Mail server setup is skipped."
    sleep 2
    echo "testing mail sending features"
    echo -e "\ngeeks@[172.16.30.48]\n"
    echo "testing geeks@[172.16.30.48]" | mail -v -s "hi geeks" geeks@[172.16.30.48] 
    echo -e "\n\ncst8246@mail.example48.lab\n"
    echo "testing cst8246@mail.example48.lab" | mail -v -s "hi cst8246" cst8246@mail.example48.lab
    echo -e "\n\ngeeks@example48.lab\n"
    echo "testing masquerading with geeks@example48.lab" | mail -v -s "testing masquerade" geeks@example48.lab
    sleep 2
    echo -e "\nDigging mail.example48.lab"
    dig mail.example48.lab
    exit 0
fi 


dnf install -y postfix mailx sendmail

# backup main.cf
cp -a /etc/postfix/main.cf{,.bak.$(date +%s)} 2>/dev/null || true

# configure postfix
# check if already configured
echo "configuring postfix"
cat $HOME/school-git/linux/mail/postfix_main > /etc/postfix/main.cf || true

# enable and start postfix
systemctl restart postfix
systemctl enable --now postfix

# add abc user if not exists
if ! id -u abc >/dev/null 2>&1; then
    useradd abc
    echo "abc:abc" | chpasswd
fi

# add mx record to fwd.example48.lab zone file
cat > /var/named/fwd.example48.lab <<EOF
\$TTL 86400
@   IN  SOA ns1.example48.lab.  dnsadmin.example48.lab. (
                    0       ; serial
                    1D      ; refresh
                    1H      ; retry
                    1W      ; expire
                    3H )    ; minimum
@   IN  NS      ns1.example48.lab.
@   IN  MX  10  mail.example48.lab.

ns1         IN  A   172.16.30.48
ftp         IN  A   172.16.32.48

www         IN  A   172.16.30.48
secure      IN  A   172.16.32.48

mail        IN  A   172.16.30.48
EOF

# restart named to apply zone file changes
systemctl restart named

# backup aliases file
cp -a /etc/aliases{,.bak.$(date +%s)} 2>/dev/null || true

# add aliases to /etc/aliases
cat $HOME/school-git/linux/mail/aliases > /etc/aliases || true
newaliases
postalias /etc/aliases
postalias -q geeks /etc/aliases

# restart postfix to apply changes
systemctl restart postfix

# configure iptables
# flush existing rules
iptables -F

# allow client and server networks to access mail server on port 25 and reject alias network
iptables -I INPUT -p tcp --dport 25 -s "172.16.30.0/24" -j ACCEPT
iptables -I INPUT -p tcp --dport 25 -s "172.16.31.0/24" -j ACCEPT
iptables -I INPUT -p tcp --dport 25 -s "172.16.32.0/24" -j REJECT

# show iptables rules
iptables --list