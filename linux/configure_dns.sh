#!/bin/bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "run as root"
    exit 1
fi

DOMAIN="example48.lab"
PRIMARY_IP="172.16.30.48"
ALIAS_IP="172.16.32.48"
CLIENT_NET="172.16.0.0/16"
REV_30_ZONE="30.16.172.in-addr.arpa"
REV_32_ZONE="32.16.172.in-addr.arpa"
SERIAL="$(date +%Y%m%d%H)"

dnf install -y bind bind-utils iptables-services
systemctl disable --now firewalld || true
systemctl enable --now named iptables

cp -a /etc/named.conf{,.bak.$(date +%s)}

cat >/etc/named.conf <<EOF
options {
    directory "/var/named";
    listen-on port 53 { 127.0.0.1; ${PRIMARY_IP}; ${ALIAS_IP}; };
    allow-query { 127.0.0.1; ${CLIENT_NET}; };
    recursion yes;
    dnssec-validation yes;
    managed-keys-directory "/var/named/dynamic";
    pid-file "/run/named/named.pid";
    session-keyfile "/run/named/session.key";
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";

zone "${DOMAIN}" IN {
    type master;
    file "fwd.${DOMAIN}";
};

zone "${REV_30_ZONE}" IN {
    type master;
    file "rev.172.16.30.db";
};

zone "${REV_32_ZONE}" IN {
    type master;
    file "rev.172.16.32.db";
};
EOF

install -o root -g named -m 0640 /dev/null /var/named/fwd.${DOMAIN}
/bin/cat >/var/named/fwd.${DOMAIN} <<EOF
\$TTL 86400
@   IN SOA ns1.${DOMAIN}. admin.${DOMAIN}. (
        ${SERIAL}
        3600
        900
        1209600
        86400
)
    IN NS ns1.${DOMAIN}.
ns1     IN A ${ALIAS_IP}
srv     IN A ${PRIMARY_IP}
ftp     IN A ${PRIMARY_IP}
client  IN A 172.16.31.48
EOF

install -o root -g named -m 0640 /dev/null /var/named/rev.172.16.30.db
/bin/cat >/var/named/rev.172.16.30.db <<EOF
\$TTL 86400
@   IN SOA ns1.${DOMAIN}. admin.${DOMAIN}. (
        ${SERIAL}
        3600
        900
        1209600
        86400
)
    IN NS ns1.${DOMAIN}.
48  IN PTR srv.${DOMAIN}.
48  IN PTR ftp.${DOMAIN}.
EOF

install -o root -g named -m 0640 /dev/null /var/named/rev.172.16.32.db
/bin/cat >/var/named/rev.172.16.32.db <<EOF
\$TTL 86400
@   IN SOA ns1.${DOMAIN}. admin.${DOMAIN}. (
        ${SERIAL}
        3600
        900
        1209600
        86400
)
    IN NS ns1.${DOMAIN}.
48  IN PTR ns1.${DOMAIN}.
EOF

restorecon -Rv /var/named >/dev/null

named-checkconf
named-checkzone "${DOMAIN}" /var/named/fwd.${DOMAIN}
named-checkzone "${REV_30_ZONE}" /var/named/rev.172.16.30.db
named-checkzone "${REV_32_ZONE}" /var/named/rev.172.16.32.db

for proto in tcp udp; do
    iptables -C INPUT -p "${proto}" --dport 53 -j ACCEPT 2>/dev/null || \
        iptables -I INPUT -p "${proto}" --dport 53 -j ACCEPT
done
service iptables save

systemctl restart named
ss -tulpn | grep :53 || true
journalctl --no-pager -u named | tail
dig @127.0.0.1 ns1.${DOMAIN} +noall +answer
dig @127.0.0.1 ftp.${DOMAIN} +noall +answer
dig @127.0.0.1 -x ${PRIMARY_IP} +noall +answer