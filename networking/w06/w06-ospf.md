# W06 — OSPF Hybrid (Cisco + MikroTik Cloud)

u = 162

x = x

(enter the first digit of the gigabit interface eg. s1 is g1/0/1, s2 is g2/0/1 etc.)

## task 1

### basic config

#### edge router

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

#### dist router

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

#### core switch

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

### ospf configuration

#### edge router 2

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

#### core switch 2

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

#### dist router 2

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

### change ospf network type to p2p on edge-dist

#### edge router 3

``` bash
interface range g0/0/1-2
    ip ospf network point-to-point
exit

```

### change network type to p2p on the edge-dist link & make dist win the DR election

#### dist router 3

``` bash
interface range g0/0/1-2
    ip ospf network point-to-point
exit

interface g0/0/2
    ip ospf priority 162
exit

```

### Reduce OSPF timers: set Hello = 3 and Dead = 10 (confirm these are compatible with the neighbour). On CORE–DIST

#### core switch 3

``` bash
interface g{x}/0/2
    ip ospf priority 0
    ip ospf hello-interval 3
    ip ospf dead-interval 10
exit

clear ip ospf process

```

#### dist router 4

``` bash
interface g0/0/2
    ip ospf priority 162
    ip ospf hello-interval 3
    ip ospf dead-interval 10
exit

clear ip ospf process

```

### update ospf router-id to 0.0.0.162 on edge router

``` bash
router ospf 162
    router-id 0.0.0.162
exit

clear ip ospf process

```

## checkpoint 1

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

### execute the script to collect proof of your configuration

#### on the lab pc

``` bash
x_remote.py w06-tsk1.yaml
```

this will generate a file named `pull0037-w06-tsk1.txt` containing command outputs

- confirm all commands ran as expected
- review the file to verify timers, dr/dbr roles, default route, router id, and loopback reachability
- ensure logs show successful syslog activity from all devices to `10.162.20.20`

tip check ur `w06-tsk1.yaml` file to see what commands are being run

### submit the generated file

#### on the lab pc again

- use **tftp64** to upload the file to the tftp server; or
- `tftp -i 192.0.2.69 put <path to file>`

---

## task 2

goal: create an isolated ospf segment between two mikrotik routers using vmware. establish internal peering and prepare the cloud for integration into the cisco network.

### vmware network configuration use vmware virtual network editor to simulate separate environments

- set **vmnet0** as a **bridged adapter** to your realtek nic (`BLACK`) — reserved for later cisco integration.
- set **vmnet1** as host-only and **disable dhcp** — this will connect `CLOUD-GW` and `CLOUD-SPK` internally.
- configure your host's **vmnet1** with the ip `10.162.45.6/29`, no gateway is needed.

#### mikrotik vm

- **clone** your mikrotik vm twice:
  - name one `CLOUD-GW`
    - name the other `CLOUD-SPK`
- network adapter settings:
  - `CLOUD-GW`:
    - adapter 1 -> vmnet1 (internal cloud)
    - adapter 2 -> vmnet0 (used later in task 3)
  - `CLOUD-SPK`:
    - adapter 1 -> vmnet1 only
- login creds: `admin/admin`

### mikrotik configuration

- when cloning/moving vm renamed the interfaces as in the network diagram (they get renamed when you move/clone them). the first nic shown in the vm settings should be labed `ether1`. if unsure goto advanced and check the mac address of the interface
- set names as `pull0037-CLOUD-GW` and `pull0037-CLOUD-SPK` (for gateway and spoke)
- create lo100 in both routers, and a lo5 in CLOUD-SPK with addr `10.162.5.5/24`
- assign ip addr to all interfaces
- ssh into both cloud routers for simplicity of use. ssh is enabled by default in mikrotik routers
- enable `OSPF-162` in both routers using the router id of the lo100
- add `AREA-0` with id `0.0.0.0` to ospf `OSPF-162`
- enable interfaces in area-0
- **verify** connectivity using `ping` from `CLOUD-GW` to `CLOUD-SPK-Lo5`
  - `/system backup save name=pull0037-cloud.backup`
  - the file will be saved on the cloud router, you can scp it to your host

using `u=162`

```python
# CLOUD routers: rename interfaces
/interface print

# ID 0 is the first interface, lower name, in this case, with MAC ending in ED;
/interface set 0 name=ether1
/interface set 1 name=ether2

# CLOUD-GW:
# Set name
/system identity set name=CLOUD-GW

# Create Lo100
/interface bridge add name=Lo100

# Assign IP address to all interfaces - Using U=250
/ip address add address=10.162.23.6/29 interface=ether2 network=10.162.23.0
/ip address add address=10.162.45.4/29 interface=ether1 network=10.162.45.0
/ip address add address=10.162.100.4 interface=Lo100 network=10.162.100.4

# Enable OSPF-250
/routing ospf instance add name=OSPF-250 router-id=10.162.100.4
/routing ospf area add instance=OSPF-250 name=AREA-0

# Enable all the interfaces in OSPF 
/routing ospf interface-template add area=AREA-0 interfaces=Lo100
/routing ospf interface-template add area=AREA-0 interfaces=ether1
/routing ospf interface-template add area=AREA-0 interfaces=ether2
```

#### verify

mikrotik uses the `print` at the end of line to print the output

```bash
# show ip addresses
/ip add print

# show ospf neighbours
/routing ospf neighbor print

# show ospf interfaces
/routing ospf interface-template print

# show ospf routes
/routing route print where ospf
```

## checkpoint 2

execute the script to collect proof of your configuration

`./x-remote/src/x_remote.py ./w06-yamls/w06-tsk2.yaml`

this will generate a file named `pull0037-w06-tsk2.txt` containing command outputs.

- confirm all commands ran as expected

*tip* check your `w06-tsk2.yaml` file to see what commands are being ran

### upload that shit

- use tftp64 to upload the file or
- `tftp -i 192.0.2.69 put <path to file>`

---

## task 3

goal connect the mikrotik cloud into the cisco campus. inject the cloud into area 0, ensure ospf roles (dr/bdr) are respected, and verify e2e default propagation to the cloud edge

### network integration

- on CLOUD-GW modify ether2 prio to 255
- cable your CLOUD routes into the phys network; cable `BLACK` to the l2-switch
- from dist, observe ospf neighbour adj formation. dist should keep the dr role
- force a new dr/bdr election
  - use `debug ip ospf adj` to monitor
  - either `clear ip ospf process` or sh/no sh `dist-g0/0/2`
  - run `undebug all` when complete
- on CLOUD-SPK verify ospf network; you should recive the 0.0.0.0 and the other ospf routes; you should be able to traceroute to the tftp server

#### mikrotik router config example

using u=162

```python
# find the id for cloud-gw ether2; mikrotik uses a default prio of 128
/routing ospf interface-template print detail

# set ether2 (id 2 - first number) prio to 255
/routing ospf interface-template set 2 priority=255
```

verify from dist:

```bash
! cloud-gw becomes the dr with prio of 255
show ip ospf neigh

! learned cloud networks
show ip route ospf | begin Gateway
```

from cloud-gw

```python
/routing route print where ospf
```

## checkpoint 3

- on 10.162.23.0/29. CLOUD-GW = dr; dist and core show correct roles per prio
- cloud-spk has a default route (0.0.0.0/0) via ospf
- full adj formed between cloud and campus devices
- traceroute from cloud-spk to tftp succeeds
