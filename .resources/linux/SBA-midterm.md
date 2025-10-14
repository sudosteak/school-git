# CST8246 Practice Lab Test – 25F

> **Note:** ALL SERVICES SHOULD BE CONFIGURED, VALIDATED AND TESTED VIA SCRIPTS. YOU MAY IMPLEMENT EACH SERVICE ONCE ONLY

## Setup Requirements

- **Fresh Install:** Set up before the exam and run `dnf update`. A clean installation is required.
- **User Account:** Create a user `lab` with password `test`. Verify SSH login using password authentication.
- **Static IP Setup:** Set the hostname as used in the lab. Configure an alias interface `172.16.32.MN`.

## Minor Services (Select TWO)

### 1. SSH

Set up user access to your server with both password and PublicKey authentication.

- Password access when `ssh lab@172.16.30.MN`
- PublicKey access when `ssh foo@172.16.30.MN`
- Ensure both authentication methods are functional.

### 2. Firewall / Netcat (NC)

Set up NC listening on port 49876. Allow access from the client network and reject all other sources.

- Server: `nc -vl 172.16.30.167 49876`
- Client: `nc -v 172.16.30.167 49876` → should connect
- Server → Server connection should be refused.

### 3. DNS

Configure a cache-only DNS server. Allow queries only from the client network (172.16.31.0/24).
Verify using `dig www.yahoo.com` on the client.

## Major Services (Select ONE)

### 4. SSH

Configure SSH for user and root access using PublicKey authentication only, from client user `cst8246`.

- `ssh foo@172.16.30.MN`
- `ssh lab@172.16.30.MN`
- `ssh root@172.16.30.MN`

### 5. Firewall / Netcat (NC)

Set up NC listening on port 55765. Allow access from the ALIAS and SERVER networks, and reject connections from the client network.

- Ncat: Connection from 172.16.30.MN → allowed
- Ncat: Connection from 172.16.32.MN → allowed
- Client → Server connection should be refused.

Document firewall rules using `firewall-cmd --list-all`.

### 6. DNS

Set up `ns1.happy.lab` with its forward zone on the server (172.16.30.MN). Allow queries from client and server networks.
Verify from both client and server using:

- `dig ns1.happy.lab`

## Marking Scheme

- **Setup:** 0 marks (required before starting the exam)
- **Two minor services:** 2 marks each (4 total)
- **One major service:** 4 marks

Total: **8 marks**
