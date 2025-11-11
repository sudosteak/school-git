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
    echo "testing geeks@[172.16.30.48]" | mail -v -s "hi geeks" geeks@[172.16.30.48] 
    echo "testing cst8246@mail.example48.lab" | mail -v -s "hi cst8246" cst8246@mail.example48.lab
    echo "testing masquerading with geeks@example48.lab" | mail -v -s "testing masquerade" geeks@example48.lab
    sleep 2
    exit 0
fi 


dnf install -y postfix mailx sendmail

# backup main.cf
cp -a /etc/postfix/main.cf{,.bak.$(date +%s)} 2>/dev/null || true

# configure postfix
sed -i 's/myhostname = .*/myhostname = mail.example48.lab/' /etc/postfix/main.cf || true
sed -i 's/#mydomain = .*/mydomain = example48.lab/' /etc/postfix/main.cf || true
sed -i 's/#myorigin = .*/myorigin = \$mydomain/' /etc/postfix/main.cf || true
sed -i 's/inet_interfaces = .*/inet_interfaces = all/' /etc/postfix/main.cf || true
sed -i 's/mydestination = \$myhostname, localhost.\$mydomain, localhost/#mydestination = \$myhostname, localhost.\$mydomain, localhost/' /etc/postfix/main.cf || true
sed -i 's/#mydestination = \$myhostname, localhost.\$mydomain, localhost, \$mydomain/mydestination = \$myhostname, localhost.\$mydomain, localhost, \$mydomain/' /etc/postfix/main.cf || true
sed -i 's/#mynetworks = .*/mynetworks = 172.16.30.0/28, 127.0.0.0/8/' /etc/postfix/main.cf || true
echo 'masquerade_domains = example48.lab' >> /etc/postfix/main.cf
sed -i 's|#home_mailbox = .*|home_mailbox = Maildir/|' /etc/postfix/main.cf || true

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

# add aliases to /etc/aliases
echo "dnsadmin: root" >> /etc/aliases
echo "geeks: cst8246, dnsadmin, abc@mail.example48.lab., cst8246@mail.example48.lab." >> /etc/aliases
newaliases
postalias /etc/aliases
postalias -q geeks

# restart postfix to apply changes
systemctl restart postfix

# allow client and server networks to access mail server on port 25 and reject alias network
iptables -I INPUT -p tcp --dport 25 -s "172.16.30.0/24" -j ACCEPT
iptables -I INPUT -p tcp --dport 25 -s "172.16.31.0/24" -j ACCEPT
iptables -I INPUT -p tcp --dport 25 -s "172.16.32.0/24" -j REJECT
