#!/bin/bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "run as root"
    exit 1
fi

# determine server role
read -p "configure as (master/slave): " ROLE
ROLE=${ROLE:-master}

DOMAIN="example48.lab"
PRIMARY_IP="172.16.30.48"
ALIAS_IP="172.16.32.48"
CLIENT_IP="172.16.31.48"
ALL_NET="172.16.0.0/16"
SERVER_NET="172.16.30.0/16"
CLIENT_NET="172.16.31.0/16"
ALIAS_NET="172.16.32.0/16"
REV_30_ZONE="30.16.172.in-addr.arpa"
REV_32_ZONE="32.16.172.in-addr.arpa"
SERIAL="$(date +%Y%m%d%H)"

dnf install -y bind bind-utils iptables-services
systemctl disable --now firewalld || true
systemctl enable --now named iptables

cp -a /etc/named.conf{,.bak.$(date +%s)} 2>/dev/null || true

if [[ "$ROLE" == "master" ]]; then
    cat >/etc/named.conf <<EOF
    options {
    directory "/var/named";
    listen-on port 53 { 127.0.0.1; ${PRIMARY_IP}; ${ALIAS_IP}; };
    allow-query { 127.0.0.1; ${ALL_NET}; };
    allow-transfer { ${CLIENT_NET}; };
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
    notify yes;
    also-notify { ${CLIENT_IP}; };
};

zone "${REV_30_ZONE}" IN {
    type master;
    file "rev.172.16.30.db";
    notify yes;
    also-notify { ${CLIENT_IP}; };
};

zone "${REV_32_ZONE}" IN {
    type master;
    file "rev.172.16.32.db";
    notify yes;
    also-notify { ${CLIENT_IP}; };
};
EOF
else
    cat >/etc/named.conf <<EOF
options {
    directory "/var/named";
    listen-on port 53 { 127.0.0.1; ${CLIENT_IP}; };
    allow-query { 127.0.0.1; ${ALL_NET}; };
    recursion yes;
    dnssec-validation yes;
    managed-keys-directory "/var/named/dynamic";
    pid-file "/run/named/named.pid";
    session-keyfile "/run/named/session.key";
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";

zone "${DOMAIN}" IN {
    type slave;
    file "slaves/fwd.${DOMAIN}";
    masters { ${PRIMARY_IP}; ${ALIAS_IP}; };
};

zone "${REV_30_ZONE}" IN {
    type slave;
    file "slaves/rev.172.16.30.db";
    masters { ${PRIMARY_IP}; ${ALIAS_IP}; };
};

zone "${REV_32_ZONE}" IN {
    type slave;
    file "slaves/rev.172.16.32.db";
    masters { ${PRIMARY_IP}; ${ALIAS_IP}; };
};
EOF
fi


if [[ "$ROLE" == "master" ]]; then
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
    IN NS ns2.${DOMAIN}.
ns1     IN A ${ALIAS_IP}
ns2     IN A ${CLIENT_IP}
srv     IN A ${PRIMARY_IP}
ftp     IN A ${ALIAS_IP}
client  IN A ${CLIENT_IP}
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
    IN NS ns2.${DOMAIN}.
48  IN PTR srv.${DOMAIN}.
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
    IN NS ns2.${DOMAIN}.
48  IN PTR ns1.${DOMAIN}.
48  IN PTR ftp.${DOMAIN}.
EOF

    restorecon -Rv /var/named >/dev/null

    named-checkconf
    named-checkzone "${DOMAIN}" /var/named/fwd.${DOMAIN}
    named-checkzone "${REV_30_ZONE}" /var/named/rev.172.16.30.db
    named-checkzone "${REV_32_ZONE}" /var/named/rev.172.16.32.db
else
    mkdir -p /var/named/slaves
    chown named:named /var/named/slaves
    restorecon -Rv /var/named >/dev/null
    named-checkconf
fi


# firewall: allow server & client nets, block alias net
for proto in tcp udp; do
    iptables -C INPUT -p "${proto}" --dport 53 -s ${SERVER_NET} -j ACCEPT 2>/dev/null || \
        iptables -I INPUT -p "${proto}" --dport 53 -s ${SERVER_NET} -j ACCEPT
    iptables -C INPUT -p "${proto}" --dport 53 -s ${CLIENT_NET} -j ACCEPT 2>/dev/null || \
        iptables -I INPUT -p "${proto}" --dport 53 -s ${CLIENT_NET} -j ACCEPT
    iptables -C INPUT -p "${proto}" --dport 53 -s ${ALIAS_NET} -j REJECT 2>/dev/null || \
        iptables -I INPUT -p "${proto}" --dport 53 -s ${ALIAS_NET} -j REJECT
done
service iptables save

systemctl restart named
echo "==================== configuration complete for ${ROLE} ===================="
cat /etc/named.conf
echo ""
ss -tulpn | grep :53 || true
echo ""
iptables -L INPUT -n --line-numbers | grep -E "(53|dpt:53)" || true
echo ""
journalctl --no-pager -u named | tail -20
echo ""

if [[ "$ROLE" == "master" ]]; then
    echo "testing master dns server:"
    dig @127.0.0.1 ns1.${DOMAIN} +noall +answer
    dig @127.0.0.1 ns2.${DOMAIN} +noall +answer
    dig @127.0.0.1 ftp.${DOMAIN} +noall +answer
    dig @127.0.0.1 -x ${PRIMARY_IP} +noall +answer
    dig @127.0.0.1 -x ${ALIAS_IP} +noall +answer
    dig @127.0.0.1 -x ${CLIENT_IP} +noall +answer
    echo ""
    echo "slave setup: run this script on client (${CLIENT_IP}) with 'slave' role"
else
    echo "waiting for zone transfers..."
    sleep 5
    ls -lah /var/named/slaves/ || echo "no transfers yet"
    echo ""
    echo "testing slave dns server:"
    dig @127.0.0.1 ns1.${DOMAIN} +noall +answer
    dig @127.0.0.1 ftp.${DOMAIN} +noall +answer
    dig @127.0.0.1 -x ${ALIAS_IP} +noall +answer
fi