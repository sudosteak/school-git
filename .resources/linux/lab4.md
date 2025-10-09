# CST8246 – DNS, Part 1

## Objectives

- Install and configure a DNS server.
- Automate the installation and configuration of a caching and authoritative DNS server.
- Verify running services and their listening ports.
- Explore newly installed packages using RPM or other package management utilities.
- Utilize log files to troubleshoot DNS-related issues.

## Lab Outcomes

- Successfully set up a caching DNS server.
- Configure an authoritative DNS server for a specified domain.
- Automate DNS setup using a script to reduce errors and streamline deployment.
- Identify and verify active DNS services and their corresponding ports.
- Use system logs to diagnose and resolve DNS configuration issues.

## Lab Deliverables

- DNS local database files configured to allow name resolution for supplied DNS names.
- Automated script that installs, configures, and validates a DNS server setup.
- A working DNS server responding to client queries.
- Full demonstration requirements listed on Brightspace (where this lab was downloaded).

## Section A – Initial Setup

### Testing Name Resolution Using Your Existing DNS Server

Before configuring your own DNS server, test your system's DNS client (stub resolver).

1. Verify your current DNS configuration.
   - Ensure that at least one name server is listed in `/etc/resolv.conf`.
   - Open a web browser and access any website to confirm that name resolution is working.
2. Test name resolution using `dig`.
   - `dig` is the recommended tool for querying DNS records.
   - Syntax: `dig [@nameserver] fqdn`.
   - Note: While `nslookup` was deprecated and later reintroduced, `dig` and `host` are preferred tools on RHEL 8.

#### Forward Lookup Test

- Use `dig` to query a domain name, for example: `dig google.com`.
- Verify the output:
  - At least one answer is returned (e.g., `ANSWER: 1`).
  - The response includes these flags:
    - `qr` (query response)
    - `rd` (recursion desired)
    - `ra` (recursion available)
  - Identify the name server that responded. Does it match the entry in `/etc/resolv.conf`?

#### Reverse Lookup Test

- Perform a reverse DNS lookup to resolve an IP address to a domain name: `dig -x <IP_address>`.

#### Querying a Specific DNS Record Type

- Look up specific DNS resource records, such as MX, SOA, or NS: `dig <record_type> <domain_name>`.
- Example: `dig NS google.ca` retrieves Google's name servers.

#### Querying a Specific Name Server

- Target a specific name server: `dig @<nameserver> <fqdn>`.

#### Tracing the DNS Delegation Path

- Trace the full DNS resolution process: `dig <fqdn> +trace`.

### Installing the DNS Server on RHEL 8

#### Installation & Setup

1. Install or update BIND (`named`).
   - Install BIND and its utilities: `dnf install bind bind-utils -y`.
   - Verify installation: `rpm -q bind bind-utils`.
   - The DNS service runs as `named`.
2. Understand the DNS client (stub resolver) in RHEL 8.
   - The stub resolver is built into `glibc` and handles name resolution.
   - Common system routines:
     - `getaddrinfo` → resolves domain names to IP addresses.
     - `getnameinfo` → resolves IP addresses to domain names.

#### Monitoring & Logging in RHEL 8

- Monitor DNS logs in real time: `journalctl -f -u named`.
- Alternatively, use the traditional log file (if enabled): `tail -f /var/log/messages`.

### Name Server Configuration Overview

A name server serves two primary roles:

1. **Caching name server**
   - Resolves domain names for local clients, typically within an internal network.
   - Handles recursive queries and caches responses to speed up future lookups.
2. **Authoritative name server**
   - Provides official DNS records for domains it manages.
   - Responds to iterative queries from other name servers.

#### Configuration Files

- The main configuration file for BIND (`/etc/named.conf`) defines:
  - Global server settings.
  - Locations of zone files, which store DNS records.
- Some distributions may not include a default `named.conf`. Check with:
  - `rpm -ql bind | grep named.conf`
- A typical BIND setup includes:
  - The primary configuration file (`named.conf`).
  - A hints file (listing root servers).
  - A zone file for each authoritative domain.

#### BIND Configuration Directives

**Global server options (`options` block)**

- Begin with a basic configuration, test it, then adjust options to match the environment.
- If a directive is missing, the default value applies.
- The `options` block defines global service settings, such as:
  - `directory` → the parent directory for DNS files (typically `/var/named`).

**Zone configuration (`zone` block)**

Each `zone` block specifies a domain for which the server is authoritative. At a minimum, include:

- Local zone (for localhost resolution).
- Reverse local zone (for reverse lookups).
- Root hints zone (used for recursive queries).

**Why the root hints zone matters**

- A caching name server queries root servers if an answer isn't in its cache.
- The hints zone provides a list of root servers for those lookups.

Example configuration for the hints zone:

```
zone "." IN {
  type hint;
  file "named.ca";
};
```

**Localhost zones**

Prevent unnecessary `localhost` queries from reaching root servers.

- Forward lookup for `localhost`:

```
zone "localhost" IN {
  type master;
  file "localhost.zone";
};
```

- Reverse lookup for `127.0.0.1`:

```
zone "1.0.0.127.IN-ADDR.ARPA" IN {
  type master;
  file "named.loopback";
};
```

**Including external configuration files**

- BIND allows configurations to be split across multiple files.
- Use `include` directives in `/etc/named.conf` to reference additional files.

Example:

```
include "/etc/named.zones";
```

### Configuring the DNS Client

Once BIND is installed, configure server and client machines to use the DNS server exclusively for name resolution. This ensures consistent behavior across the network.

#### Steps to configure the DNS resolver

1. **Modify `/etc/resolv.conf`**
   - Before testing BIND, comment out any existing `nameserver` entries.
   - This prevents false positives during testing.
2. **On the DNS server**
   - Add the loopback address (`127.0.0.1`) to the resolver configuration.
   - Example entry:
     - `nameserver 127.0.0.1`
   - (Optional) Specify the domain using the `search` directive for the resolver library.
     - Example: `search exampleMN.lab`
3. **On client machines**
   - Configure each client to use the DNS server's IP address.
   - Example: `nameserver 192.168.1.1`

#### Preventing DHCP from overwriting DNS settings

If the system uses DHCP, `/etc/resolv.conf` might be overwritten on network restart.

- Edit the network interface configuration file (e.g., `/etc/sysconfig/network-scripts/ifcfg-<interface>`).
- Add: `PEERDNS=no`
- This stops DHCP from modifying DNS settings automatically.

## Section B – BIND Configuration: Caching-Only Name Server

A caching-only name server isn't authoritative for any zone. It resolves domain names for internal clients and caches responses for faster future lookups. Existing configurations often default to this mode.

### Configuring a Caching-Only Name Server

1. **Create or modify `/etc/named.conf`**
   - Back up the existing configuration before making changes.
   - You can reuse the existing file (at your own risk).
2. **Essential configuration steps**
   - Add the `directory` directive for the working directory.
   - Include the `hints` zone for root server resolution.
   - Include zone files for the localhost zone in a separate configuration file.
     - You can use the default `named.rfc1912.zones` file bundled with BIND; just reference it correctly.

### Starting the Name Server

Open four terminal sessions for monitoring and testing:

- One for the BIND service.
- One for viewing logs (`journalctl -f -u named`).
- One for client queries.
- One for checking active network connections (`ss`).

Key actions:

- Start or restart the BIND service.
- Check log output for errors or important messages.
- Verify that the service runs and listens on the correct interfaces/ports using:
  - `ss -tulnp | grep named`

## Section C – BIND Configuration: Authoritative Name Server

An authoritative name server manages and provides authoritative responses for one or more DNS zones. It primarily serves external clients (other name servers).

To configure your name server as authoritative for the `exampleMN.lab` zone, complete these steps.

### Step 1: Create the Zone Files

- Define the necessary DNS records for your domain.

### Step 2: Update the BIND Configuration

- Modify the configuration file to include zone directives for each authoritative domain.

#### Required zone directives

At minimum, include:

- Hints zone – identifies root servers (optional but recommended).
- Localhost forward zone – prevents forwarding localhost queries to root servers.
- Localhost reverse zone – provides reverse lookup for localhost.
- Forward zone(s) – defines domains for which the server is authoritative.
- Reverse zone(s) – provides reverse DNS resolution for authoritative domains.

### Part 1: Setting Up a Forward Zone File

A forward zone file defines DNS records for a domain. It typically includes:

- Default TTL (time to live)
- Comment section describing the zone
- SOA (Start of Authority) record (primary name server and admin contact)
- NS (name server) records
- A (address) records mapping hostnames to IPs

#### Example zone file entries

- **Default TTL**: `$TTL 86400  # 24 hours`
- **Origin directive**: `$ORIGIN example.net.`
- **SOA record**:

```
@ IN SOA ns1.example.net. dnsadm.example.net. (
  2000122401  ; Serial Number (use date + revision)
  28800       ; Refresh (8h)
  14400       ; Retry (4h)
  604800      ; Expire (1w)
  10800       ; Minimum TTL (3h)
)
```

- **NS record**: `example.net. IN NS ns1.example.net.`
- **A record for the name server**: `ns1 IN A 192.168.1.1`
- **A record for an FTP server**: `ftp IN A 192.168.1.2`

#### Configuring the forward zone file for `exampleMN.lab`

- Create a forward zone file named `fwd.exampleMN.lab` in the BIND configuration directory.
- Include the following records:
  - Default TTL value.
  - Comment section identifying the zone.
  - SOA record.
  - NS record for `ns1.exampleMN.lab`.
  - A record for `ns1.exampleMN.lab`.
  - A record for `ftp.exampleMN.lab` with the assigned IP address.

### BIND Configuration Update

- In `/etc/named.conf`, add a `zone` block for the forward zone.
- Since this is the master DNS server, set `type master`.
- Reference the zone file correctly.

Example configuration:

```
zone "exampleMN.lab" IN {
  type master;
  file "/etc/named/fwd.exampleMN.lab";
};
```

### Testing Your Name Server

1. Start the BIND service.
2. Verify the service status:
   - `ss -tulnp | grep named`
3. Check logs for successful zone loading:
   - `journalctl -f -u named`
4. Run BIND utilities to check for syntax errors:
   - `named-checkconf`
   - `named-checkzone exampleMN.lab /etc/named/fwd.exampleMN.lab`

#### Testing with `dig`

Use `dig` to confirm the authoritative server works (record results).

- `dig ns1.exampleMN.lab`
  - Expect the query to succeed and include the `aa` (authoritative answer) flag.
- `dig ftp.exampleMN.lab`
  - Expect the query to return the correct IP address.
- `dig NS exampleMN.lab`
  - Expect the output to list `ns1.exampleMN.lab` as the authoritative name server.
- `dig SOA exampleMN.lab`
  - Expect the SOA record with the primary name server and admin contact.

## Procedure

1. **Ensure firewall configuration**
   - Disable rules that interfere with DNS operation, or automate firewall rules with `firewalld` or `iptables`.
2. **Automate DNS installation and configuration**
   - Develop a setup script that:
     - Installs the BIND DNS packages (`bind` and `bind-utils`).
     - Configures the caching DNS server (`/etc/named.conf`).
     - Sets up zone files for the authoritative DNS server.
     - Restarts and enables the DNS service (`named`).
     - Updates firewall rules to allow DNS traffic on UDP/TCP port 53.
3. **Testing and verification**
   - Use `dig` and `nslookup` to query the DNS server and verify responses.
   - Run `ss -tulnp` or `netstat -tulnp` to confirm DNS is listening on port 53.
   - Check `journalctl -u named` and `/var/log/messages` for errors.
4. **Troubleshooting**
   - If the DNS server isn't responding, review `named.conf` for syntax errors.
   - Validate zone files with `named-checkconf` and `named-checkzone`.
