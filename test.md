# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Context7 Integration

Always use Context7 when I need code generation, setup or configuration steps, or library/API documentation. This means you should automatically use the Context7 MCP tools to resolve library id and get library docs without me having to explicitly ask.

## Repository Overview

This is a collection of scripts and code for school assignments across multiple courses:

- **Linux system administration** (RHEL 8.10 focused)
- **Networking** (Cisco ENARSI, OSPF configuration)
- **Python programming** (introductory labs)
- **Windows administration**

Scripts are primarily for lab assignments and Skills-Based Assessments (SBAs). The repository includes reference materials in `.resources/` containing assignment PDFs and markdown specifications.

## Magic Number Convention

Throughout Linux SBA scripts, a "Magic Number" (MN) is used as a student identifier for IP addressing and configuration. Currently set to `48`:

- Server IP: `172.16.30.48`
- Client IP: `172.16.31.48`
- Alias IP: `172.16.32.48`

This MN appears in `setup.sh`, `major.sh`, `minor1.sh`, `minor2.sh` and should remain consistent across all SBA scripts.

## Linux SBA Scripts

Located in `linux/sba/midterm/`, these scripts automate RHEL 8.10 VM configuration for midterm assessments. **They must be run in order:**

1. **setup.sh** - Initial VM configuration (run first as root)
   - System updates, SSH setup, hostname configuration
   - Network interface setup with static IPs (172.16.30.MN and alias 172.16.32.MN)
   - Wheel group sudo configuration (NOPASSWD)
   - Iptables firewall initialization (replaces firewalld)
   - Creates user accounts for SSH access

2. **minor1.sh** - SSH authentication setup
   - Configures password authentication for 'lab' user
   - Configures public key authentication for 'foo' user
   - Generates SSH key pairs and authorized_keys

3. **minor2.sh** - Netcat firewall configuration
   - Configures iptables rules for netcat service
   - Allows connections from client network (172.16.31.0/24)
   - Rejects connections from server network and all other sources

4. **major.sh** - DNS server configuration
   - Installs and configures BIND DNS server
   - Creates forward zone for green.lab domain
   - Creates reverse zone for 16.172.in-addr.arpa
   - Configures dns1.green.lab pointing to server IP
   - Sets up iptables rules for DNS (port 53)
   - Allows queries from client (172.16.31.0/24) and server (172.16.30.0/24) networks

### Common Script Patterns

All SBA scripts share:

- Bash strict mode: `set -euo pipefail`
- Colored output functions: `print_status()`, `print_error()`, `print_info()`
- Root privilege checking
- Service validation and testing after configuration
- Backup of existing configuration files before modification

### Firewall Architecture

The SBA environment uses **iptables** (not firewalld):

- Firewalld is stopped and masked in setup.sh
- Rules are managed via iptables-services package
- Rules must be saved with `service iptables save`
- Default policies are ACCEPT, specific rules added for services

## Networking Scripts

### x_remote.py (Remote Cisco Configuration Tool)

Located in `networking/w06/x-remote/src/`, this Python script automates command execution on Cisco devices via SSH using Netmiko.

**Usage:**

```bash
python x_remote.py <yaml_file>
```

**YAML file format** (see `networking/w06/w06-yamls/*.yaml`):

```yaml
output_file: output-filename.txt
devices:
  - device_info:
      device_type: cisco_xe
      ip: 10.162.100.1
      username: admin
      password: cisco
    commands:
      - show ip ospf neighbor
      - show ip route
```

The script:

- Reads device info and commands from YAML
- Connects via SSH using Netmiko
- Executes commands sequentially
- Logs all output to specified file and stdout
- Handles connection failures gracefully

## Python Environment

Python scripts are in `python/pysrc.d/` organized by lab (lab2, lab3, lab4, lab5). A virtual environment exists at `.venv/`.

**Setup:**

```bash
source .venv/bin/activate
```

Most Python scripts are basic exercises (loops, conditionals, functions) and don't require external dependencies beyond the standard library, except for networking scripts which need:

```bash
pip install netmiko pyyaml
```

## Directory Structure

```text
├── linux/                 # Linux admin scripts
│   ├── sba/midterm/      # SBA midterm automation scripts (setup.sh, major.sh, minor1.sh, minor2.sh)
│   └── *.sh              # Standalone utility scripts (testnet.sh, openssh.sh, etc.)
├── networking/
│   └── w06/              # Week 6 ENARSI assignments
│       ├── x-remote/src/ # x_remote.py SSH automation tool
│       └── w06-yamls/    # YAML config files for x_remote.py
├── python/pysrc.d/       # Python lab exercises organized by lab number
├── windows/              # Windows administration materials
├── .resources/           # Assignment PDFs and specifications
└── .venv/                # Python virtual environment

```

## Git Workflow

- Main branch: `main`
- Recent commits show iterative refinement of SBA scripts
- Commit messages follow pattern: `type: description` (e.g., "feat: added major and both minor sba scripts")

## Testing and Validation

For Linux SBA scripts:

- Each script includes validation steps (e.g., `named-checkzone`, `named-checkconf` for DNS)
- Scripts display configuration summaries after completion
- Built-in connectivity tests (ping, dig, netcat) are included
- Check systemctl status for services: `systemctl status named`, `systemctl status sshd`

For networking scripts:

- Test x_remote.py against YAML configs in w06-yamls/
- Output files are named with student username prefix (e.g., pull0037-w06-tsk1.txt)
