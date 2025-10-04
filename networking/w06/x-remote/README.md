# x_remote

x_remote is a Python script designed to collect configuration information from network devices (e.g., Cisco, Mikrotik, Linux) via SSH. The script executes a set of commands provided in a YAML file and stores the results in a log file.

## Features

- Supports SSH connections to multiple device types (Cisco, Mikrotik, Linux).
- Collects command output and logs it in a single or multiple output files.
- Uses a YAML file to specify device information and commands to run.
- Default login credentials: `admin/admin` (can be configured per device).
- Supports both individual device logs and a global output log.

## Requirements

To use `x_remote`, the following dependencies are required:

- Python 3.x
- `netmiko`
- `pyyaml`

You can install the dependencies using the `requirements.txt` file provided in this repository:

```bash
pip install -r requirements.txt
```


## Installation

1. **Clone the repository**:
    
    ```bash
    git clone https://github.com/YOUR_USERNAME/x_remote.git cd x_remote
    ```
    
2. **Install the dependencies**:
    
    ``` bash
	pip install -r requirements.txt
    ```
    
## Usage

The `x_remote.py` script uses a YAML file to define the devices and commands to be executed on each device. You can provide the YAML file as input to the script, as well as the location to store the output log.

### YAML File Structure

The YAML file should have the following structure:

``` yaml
output_file: /path/to/output.log 
devices:   
- device_info:       
	- device_type: mikrotik_routeros       
	- ip: 192.168.100.1       
	- username: admin       
	- password: password     
- commands:       
	- /routing/isis/neighbor/print       
	- /ip/route/print detail   
- device_info:       
	- device_type: cisco_ios       
	- ip: 192.168.100.2       
	- username: admin       
	- password: password     
	- commands:       
		- show ip int brief | exclude unassigned       
		- show running-config`

```

### Running the Script

To run the script, use the following command:

``` bash
python x_remote.py --commands /path/to/your/commands.yaml 

- `--commands`: Path to the YAML file containing the device information and commands.
```

### Example Command

``` bash
python x_remote.py --commands isis_commands.yaml
```

### Output

- The output will be saved to a log file either specified in the YAML file or defaulting to `log_YYYY-MM-DD_HH-MM-SS.txt`.
- If no `output_file` is defined in the YAML, the script will create individual log files per device, named by their IP address.

## Contributing

Feel free to open issues or submit pull requests. Contributions are welcome!

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.