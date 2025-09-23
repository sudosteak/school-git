# OSPF Configuration Script for pull0037 Network

hostname pull0037-EDGE
enable secret class
username admin privilege 15 secret cisco
line vty 0 15
login local
transport input ssh
logging synch
exit
line con 0
logging synch
exit
ip domain-name cnap.cst
crypto key gen rsa general-keys modulus 2048
no ip domain-lookup
ntp master 4

int lo100
ip addr 10.162.100.1 255.255.255.255
exit

int g0/0/0
ip addr 203.0.113.162 255.255.255.0
exit

int g0/0/1
ip addr 10.162.12.1 255.255.255.248
exit

int g0/0/2
ip addr 10.162.13.1 255.255.255.248
exit

---

hostname pull0037-DIST
enable secret class
username admin privilege 15 secret cisco
line vty 0 15
login local
transport input ssh
logging synch
exit
line con 0
logging synch
exit
ip domain-name cnap.cst
crypto key gen rsa general-keys modulus 2048
no ip domain-lookup
ntp server 10.162.100.1

int lo100
ip addr 10.162.100.3 255.255.255.255
exit

int g0/0/1
ip addr 10.162.13.3 255.255.255.248
exit

int g0/0/2
ip addr 10.162.23.3 255.255.255.248
exit

---

hostname pull0037-CORE
enable secret class
username cisco privilege 15 secret class
line vty 0 15
login local
transport input ssh
logging synch
exit
line con 0
logging synch
exit
ip domain-name cnap.cst
crypto key gen rsa general-keys modulus 2048
no ip domain-lookup
ip routing

vlan 20
name pull0037-VLAN20
exit

vlan 666
name pull0037-VLAN666

int lo100
no switchport
ip addr 10.162.100.1 255.255.255.255
exit

int g3/0/1
no switchport
ip addr 10.162.12.2 255.255.255.248
exit

int g3/0/2
no switchport
ip addr 10.162.23.2 255.255.255.248
exit

int vlan20
ip addr 10.162.20.2 255.255.255.0
exit
