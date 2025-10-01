# Copilot Instructions for School Git Repository

## Project Overview
This is a personal academic repository containing scripts and assignments for three courses:
- **CST8245**: Python beginners course (`/python/`)
- **CST8246**: Enterprise Linux (RHEL-based) course (`/linux/`)
- **Enterprise Networking**: Router/network configuration course (`/networking/`)

Files are organized by subject area with lab/week-based subdirectories.

## Project Structure

### `/python/pysrc.d/`
- Lab exercises organized sequentially: `lab2/`, `lab3/`, `lab4/`, `lab5/`
- Each lab contains standalone Python scripts for specific assignments
- `syntax_practice/` subdirectories contain smaller practice exercises
- **File naming**: Use Python conventions - lowercase with underscores (e.g., `guess_number.py`, `simple_calculator.py`)

### `/linux/`
- Bash scripts for network and firewall configuration
- All scripts require root privileges (check with `EUID -ne 0`)
- Target environment: RHEL-based Linux systems with iptables/NetworkManager
- **File naming**: Use Python conventions - lowercase with underscores (e.g., `iptables_rules.sh`, not `FWrules.sh`)

### `/networking/`
- Router configuration scripts organized by week: `w04/`, `w05/`
- Cisco IOS configuration files (`.txt` format) for OSPF routing
- Network identifier: `pull0037` with U=162

## Code Conventions

### Python Scripts
**File Header (Required):**
```python
#!/usr/bin/python3

"""
    program name: script_name.py
    program purpose: [description]
    author: Jacob P, 041156249, 010
    date & version: DD-MM-YYYY, version: X.X
    completion time: [estimate]
"""
```

**Style Patterns:**
- Lowercase variable names with underscores: `user_input`, `first_operand`
- Constants in UPPERCASE: `COURSE_CODE`, `CLIENT_IP`
- Lowercase user-facing messages (prompts/output)
- Lowercase comments: `# get the first guess from the user`
- F-strings for formatting: `f"{variable} is incorrect"`

### Bash Scripts
**Common Patterns:**
- Shebang: `#!/bin/bash`
- Root check at start: `if [[ $EUID -ne 0 ]]; then echo "..."; exit 1; fi`
- Default values: `${variable:-default_value}`
- User prompts with defaults: `read -p "Enter... (default: value): " VAR`
- Variables: UPPERCASE for configuration, lowercase for user input

**Network Script Conventions:**
- Interface names: `enp2s0` (red), `enp1s0` (blue) as defaults
- IP scheme: `172.16.x.x` for internal networks
- Always display final state with line numbers: `iptables -L -n --line-numbers`

### Cisco IOS Config Files
**Standard Sections (in order):**
1. Hostname configuration
2. Enable secret & user accounts (`enable secret class`, `username admin privilege 15 secret cisco`)
3. Line configuration (vty 0 15, console 0)
4. SSH setup (domain-name, crypto key gen rsa)
5. Logging & NTP configuration
6. Interface configurations (lo100 for management, then physical interfaces)

**Network Identifiers:**
- Format: `pull0037-ROLE` (e.g., `pull0037-EDGE`, `pull0037-DIST`, `pull0037-CORE`)
- Loopback: `10.162.100.x` (x=1 for EDGE, x=3 for DIST, etc.)
- Always include `no ip domain-lookup` to prevent DNS delays

## Development Environment
- Python: Virtual environment in `.venv/` (optional, from previous project - not required for basic scripts)
- Execute Python: `python3 script.py` or `./script.py` (with shebang)
- Bash scripts: Must run with `sudo` for system/network operations
- Network configs: Copy-paste into Cisco devices via console/SSH

## Naming Conventions
- **All files**: Use Python naming style - lowercase with underscores
- Python scripts: `guess_number.py`, `simple_calculator.py`
- Bash scripts: `iptables_rules.sh`, `testnet.sh`
- Directories: `syntax_practice/`, `lab2/`, `w04/`

## Testing & Validation
- Python: Run scripts interactively to test input/output flow
- Bash (network): Test with `ping`, check `iptables -L -n`, verify `systemctl is-active`
- Cisco: Verify with `show ip interface brief`, `show ip ospf neighbor`

## Key Files to Reference
- Python docstring example: `python/pysrc.d/lab2/calc_sequential.py`
- Root check pattern: `linux/iptables_rules.sh`
- Network testing script: `linux/testnet.sh`
- Cisco config template: `networking/w04/w04-ospf-script.txt`
