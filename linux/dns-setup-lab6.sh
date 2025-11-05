#!/bin/bash
# lab 4/5
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "run as root"
    exit 1
fi

# determine server role

domain="example48.lab"
server="172.16.30.48"
alias="172.16.32.48"
client="172.16.31.48"
net="172.16.0.0/16"
rev="16.172.in-addr.arpa"

# query if bind and bind-utils is installed
if ! rpm -q bind bind-utils iptables-services >/dev/null 2>&1; then
    echo "installing bind, bind-utils, and iptables-services..."
    dnf install -y bind bind-utils iptables-services
fi

iptables -F || true
systemctl disable --now firewalld || true
systemctl enable --now named iptables

cp -a /etc/named.conf{,.bak.$(date +%s)} 2>/dev/null || true

echo ""
echo "==================== named configuration for ${HOSTNAME} ===================="
echo ""

if [[ "$HOSTNAME" == "pull0037-SRV.example48.lab" ]]; then
    cat >/etc/named.conf <<EOF
options {
    listen-on port 53 { 127.0.0.1; ${server}; };
    listen-on-v6 port 53 { ::1; };
    directory "/var/named";
    dump-file "/var/named/data/cache_dump.db";
    statistics-file "/var/named/data/named_stats.txt";
    memstatistics-file "/var/named/data/named_mem_stats.txt";
    secroots-file "/var/named/data/named.secroots";
    recursing-file "/var/named/data/named.recursing";
    allow-query { localhost; ${net}; };
    allow-recursion { ${net}; };
    //allow-transfer { localhost; ${client}; }; // list of slaves allowed to transfer zone

    recursion yes;

    dnssec-enable yes;
    dnssec-validation yes;

    managed-keys-directory "/var/named/dynamic";

    pid-file "/run/named/named.pid";
    session-keyfile "/run/named/session.key";    

    include "/etc/crypto-policies/back-ends/bind.config";
};

logging {
    channel default_debug {
        file "data/named.run";
        severity dynamic;
    };
};

// root name server in "hints" file
zone "." IN {
    type hint;
    file "named.ca";
};

// master for forward zone ${domain}
zone "${domain}" IN {
    type master;
    file "fwd.${domain}";
    allow-update { none; };
    allow-transfer { ${client}; }; // list of slaves allowed to transfer zone
};

// master for reverse zone ${domain}
zone "${rev}" IN {
    type master;
    file "rvs.${domain}";
    allow-update { none; };
    allow-transfer { ${client}; }; // list of slaves allowed to transfer zone
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
EOF
else
    cat >/etc/named.conf <<EOF
options {
    listen-on port 53 { 127.0.0.1; ${client}; };
    listen-on-v6 port 53 { ::1; };
    directory "/var/named";
    dump-file "/var/named/data/cache_dump.db";
    statistics-file "/var/named/data/named_stats.txt";
    memstatistics-file "/var/named/data/named_mem_stats.txt";
    secroots-file "/var/named/data/named.secroots";
    recursing-file "/var/named/data/named.recursing";
    allow-query { localhost; ${net}; };
    allow-transfer { none; };
    recursion yes;
    dnssec-enable yes;
    dnssec-validation yes;
    bindkeys-file "/etc/named.root.key";
    managed-keys-directory "/var/named/dynamic";
    pid-file "/run/named/named.pid";
    session-keyfile "/run/named/session.key";
};
logging {
    channel default_debug {
        file "data/named.run";
        severity dynamic;
    };
};
// root name server in "hints" file
zone "." IN {
    type hint;
    file "named.ca";
};
// slave for forward zone ${domain}
zone "${domain}" IN {
    type slave;
    file "slaves/fwd.${domain}";
    masters { ${server}; };
};
// slave for reverse zone ${domain}
zone "${rev}" IN {
    type slave;
    file "slaves/rvs.${domain}";
    masters { ${server}; };
};
include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
EOF
fi

# Add || true to named-checkzone commands (may fail on first run)
if [[ "$HOSTNAME" == "pull0037-SRV.example48.lab" ]]; then
    cat >/var/named/fwd.${domain} <<EOF
\$TTL 86400
@   IN  SOA ns1.${domain}.  dnsadmin.${domain}. (
                    0       ; serial
                    1D      ; refresh
                    1H      ; retry
                    1W      ; expire
                    3H )    ; minimum
@   IN  NS  ns1.${domain}.
@   IN  NS  ns2.${domain}.
@   IN  NS  ftp.${domain}.
ns1 IN  A   ${server}
ns2 IN  A   ${client}
ftp IN  A   ${alias}
EOF

    cat >/var/named/rvs.${domain} <<EOF
\$TTL 1D
@   IN  SOA ns1.${domain}.  dnsadmin.${domain}. (
                    0       ; serial
                    1D      ; refresh
                    1H      ; retry
                    1W      ; expire
                    3H )    ; minimum
@   IN  NS  ns1.${domain}.
@   IN  NS  ns2.${domain}.

48.30   IN  PTR ns1.${domain}.
48.31   IN  PTR ns2.${domain}.
48.32   IN  PTR ftp.${domain}.
EOF

    cat >/etc/resolv.conf <<EOF
search localhost $domain
nameserver $server
EOF

    chown root:named /var/named/fwd.${domain} /var/named/rvs.${domain}

    named-checkzone forward /var/named/fwd.${domain} || { echo "WARNING: forward zone check failed"; }
    named-checkzone reverse /var/named/rvs.${domain} || { echo "WARNING: reverse zone check failed"; }

    /usr/sbin/named-checkconf -z /etc/named.conf || { echo "ERROR: named.conf validation failed"; exit 1; }
else
    cat >/etc/resolv.conf <<EOF
search localhost $domain
nameserver $server
EOF

    mkdir -p /var/named/slaves
    chown root:named /var/named/slaves

    /usr/sbin/named-checkconf -z /etc/named.conf
    
    systemctl restart named
    sleep 3  # allow time for zone transfer
    
    if [[ ! -f /var/named/slaves/fwd.${domain} ]]; then
        echo "warning: forward zone not transferred yet"
    fi
    if [[ ! -f /var/named/slaves/rvs.${domain} ]]; then
        echo "warning: reverse zone not transferred yet"
    fi
fi


# firewall rules: allow client and server networks access to the dns (53) port and reject alias ip
iptables -I INPUT -p udp --dport 53 -s "172.16.30.0/24" -j ACCEPT || true
iptables -I INPUT -p tcp --dport 53 -s "172.16.31.0/24" -j ACCEPT || true

# block dns queries from alias ip 
iptables -I INPUT -p udp --dport 53 -s "172.16.32.0/24" -j REJECT || true
iptables -I INPUT -p tcp --dport 53 -s "172.16.32.0/24" -j REJECT || true

# Save iptables rules so they persist after reboot
service iptables save || echo "WARNING: could not save iptables rules"

systemctl restart named || { echo "ERROR: named failed to restart"; journalctl -xeu named; exit 1; }
echo ""
echo "==================== configuration complete for ${HOSTNAME} ===================="
echo ""
netstat -tulpn | grep :53 || true
echo ""
iptables -L INPUT -n --line-numbers 
echo ""
echo ""
echo "==================== dig for $server, $client and $alias ===================="
echo ""
if [[ "$HOSTNAME" == "pull0037-SRV.example48.lab" ]]; then
    echo "digging ns1 (${server})"
    dig -x ${server}

    echo "digging ns2 (${client})"
    dig -x ${client}

    echo "digging ftp (${alias})"
    dig -x ${alias}

    echo ""
    echo "master setup done"
else
    echo "digging ns1 (${server})"
    dig -x ${server}

    echo "digging ns2 (${client})"
    dig -x ${client}

    echo "digging ftp (${alias})"
    dig -x ${alias}

    echo ""
    echo "slave setup done"
fi

# END OF SCRIPT