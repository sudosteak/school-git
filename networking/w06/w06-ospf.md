# W06 — OSPF Hybrid (Cisco + MikroTik Cloud)

u = 162

x = x

(enter the first digit of the gigabit interface eg. s1 is g1/0/1, s2 is g2/0/1 etc.)

## basic config

### edge router

``` bash
hostname pull0037-EDGE
enable secret class
username admin privilege 15 secret cisco
service password-encryption

line vty 0 15
    login local
    transport input ssh
    logging synchronous
exit

line console 0
    logging synchronous
exit

ip domain-name cnap.cst
crypto key gen rsa general-keys modulus 2048
no ip domain-lookup

ntp master 4
logging host 10.162.20.20
logging trap informational
logging source-interface lo100

interface lo100
    ip address 10.162.100.1 255.255.255.255
exit

interface g0/0/0
    ip address 203.0.113.162 255.255.255.0
exit

interface g0/0/1
    ip address 10.162.12.1 255.255.255.248
exit

interface g0/0/2
    ip address 10.162.13.1 255.255.255.248
exit

no ip tftp source-interface

```

### dist router

``` bash
hostname pull0037-DIST
enable secret class
username admin privilege 15 secret cisco
service password-encryption

line vty 0 15
    login local
    transport input ssh
    logging synchronous
exit

line console 0
    logging synchronous
exit

ip domain-name cnap.cst
crypto key generate rsa general-keys modulus 2048
no ip domain-lookup

ntp server 10.162.100.1
logging host 10.162.20.20
logging trap informational
logging source-interface lo100

interface lo100
    ip address 10.162.100.3 255.255.255.255
exit

interface g0/0/1
    ip address 10.162.13.3 255.255.255.248
exit

interface g0/0/2
    ip address 10.162.23.3 255.255.255.248
exit

```

### core switch

``` bash
hostname pull0037-CORE
enable secret class
username cisco privilege 15 secret class
service password-encryption

line vty 0 15
    login local
    transport input ssh
    logging synchronous
exit

line console 0
    logging synchronous
exit

ip domain-name cnap.cst
crypto key generate rsa general-keys modulus 2048
no ip domain-lookup
ip routing

ip domain-name cnap.cst
crypto key generate rsa general-keys modulus 2048
no ip domain-lookup

ntp server 10.162.100.1
logging host 10.162.20.20
logging trap informational
logging source-interface lo100

vlan 20
    name pull0037-VLAN20
exit

vlan 666
    name pull0037-VLAN666
exit

interface lo100
    ip address 10.162.100.1 255.255.255.255
exit

interface g{x}/0/1
    no switchport
    ip address 10.162.12.2 255.255.255.248
exit

interface g{x}/0/2
    no switchport
    ip address 10.162.23.2 255.255.255.248
exit

interface vlan20
    ip address 10.162.20.2 255.255.255.0
exit

interface g{x}/0/20
    no shutdown
    switchport mode access
    switchport access vlan 20
exit


default route on edge router
ip route 0.0.0.0 0.0.0.0 g0/0/0 203.0.113.254

```

## ospf configuration

### edge router 2

``` bash
router ospf 162
    router-id 10.162.100.1
    auto ref 10000
exit

interface lo100
    ip ospf 162 area 0
exit

interface range g0/0/1-2
    ip ospf 162 area 0
exit

```

### core switch 2

``` bash
router ospf 162
    router-id 10.162.100.2
    auto ref 10000
exit

interface lo100
    ip ospf 162 area 0
exit

interface range g{x}/0/1-2 g{x}/0/20
    ip ospf 162 area 0
exit

interface vlan20
    ip ospf 162 area 0
exit

router ospf 162
    passive-interface vlan20
exit

```

### dist router 2

``` bash
router ospf 162
    router-id 10.162.100.3
    auto ref 10000
exit

interface lo100
    ip ospf 162 area 0
exit

interface range g0/0/1-2
    ip ospf 162 area 0
exit

```

## change ospf network type to p2p on edge-dist

### edge router 3

``` bash
interface range g0/0/1-2
    ip ospf network point-to-point
exit

```

## change network type to p2p on the edge-dist link & make dist win the DR election

### dist router 3

``` bash
interface range g0/0/1-2
    ip ospf network point-to-point
exit

interface g0/0/2
    ip ospf priority 162
exit

```

## Reduce OSPF timers: set Hello = 3 and Dead = 10 (confirm these are compatible with the neighbour). On CORE–DIST

### core switch 3

``` bash
interface g{x}/0/2
    ip ospf priority 0
    ip ospf hello-interval 3
    ip ospf dead-interval 10
exit

clear ip ospf process

```

### dist router 4

``` bash
interface g0/0/2
    ip ospf priority 162
    ip ospf hello-interval 3
    ip ospf dead-interval 10
exit

clear ip ospf process

```

## update ospf router-id to 0.0.0.162 on edge router

``` bash
router ospf 162
    router-id 0.0.0.162
exit

clear ip ospf process

```

## c01

- all ospf adjacencies should be full
- dist is the dr on edge-dist and core-dist segments, as configured
- hello/dead timers are correctly applied on the edge-dist link
- core vlan20 is part of ospf and correctly marked as passive in area 0
- all routers use the correct ospf reference bandwidth value
- all loopbacks are advertised and reachable across the domain
- edge router id is updated to 0.0.0.162 and recognized by all neighbours
- all routers have the default route via edge
- traceroute from pc to the tftp server follows the expected path through edge
- all routers have the same number of ospf lsas in their databases
- core and dist show ntp sync status with edge
- syslog messages from all devices are received and logged on the pc.

## execute the script to collect proof of your configuration

### on the lab pc

``` bash
x_remote.py w06-tsk1.yaml
```
