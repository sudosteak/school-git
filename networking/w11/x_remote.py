#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
x_remote: A utility to execute a set of commands on different devices using SSH.
The script reads a YAML file with device information and commands to execute.

Usage:
    python x_remote.py --commands verification_commands.yaml

Author: C. Ayala - ayalac@algonquincollege.com
Date: September 16th 2024

"""
# TODO:  1. Rename script to xremote.
# TODO:  2. Create a hash to write into the file to ensure uniqueness in the execution of the commands

import os
import sys
import yaml
import argparse
import logging
from datetime import datetime
from netmiko import ConnectHandler, NetMikoTimeoutException, NetMikoAuthenticationException


def parse_arguments():
    """Parse the command-line arguments."""
    parser = argparse.ArgumentParser(description="SSH into a device and execute commands.")

    parser.add_argument("commands", help="Yaml file with commands to run on the device.")
    return parser.parse_args()


def read_yaml_commands(commands):
    """Read devices and commands from the YAML file."""

    if not os.path.isfile(commands):
        logging.error(f"Commands file {commands} does not exist.")
        sys.exit(1)

    with open(commands, 'r') as file:
        try:
            data = yaml.safe_load(file)
        except yaml.YAMLError as exc:
            logging.error(f"Error reading YAML file: {exc}")
            sys.exit(1)

    # Extract output_file
    output_file = data.get('output_file', None)

    # Extract the device info and commands
    devices = []
    for device_entry in data.get('devices', []):
        device_info = device_entry.get('device_info')
        commands = device_entry.get('commands', [])
        devices.append((device_info, commands))

    return devices, output_file


def establish_ssh_connection(device_info):
    """Establish SSH connection to the device using netmiko."""

    try:
        logging.info(f"Connecting to {device_info['ip']}...")
        connection = ConnectHandler(**device_info)
        logging.info(f"Successfully connected to {device_info['ip']}.")
        return connection
    except NetMikoTimeoutException:
        logging.error(f"Connection timed out for {device_info['ip']}.")
    except NetMikoAuthenticationException:
        logging.error(f"Authentication failed for {device_info['ip']}.")
    except Exception as e:
        logging.error(f"An error occurred while connecting to {device_info['ip']}: {str(e)}")
        return None


def execute_commands(connection, commands, log_file):
    """Execute the list of commands on the device and log the output."""
    output = []  # To collect all outputs before writing to the log

    for command in commands:
        # Write the command to the output
        output.append('\n' + '+' + '-' * 80)
        output.append(f"|Command: {command}")
        output.append('+' + '-' * 80)

        # Execute the command
        result = connection.send_command(command)

        # Append the result of the command to the output
        output.append(result)

        # Write the collected output to the log file and print to the screen
        log_file.write("\n".join(output))  # Write everything to the log
        log_file.flush()  # Ensure data is written to the file

        print("\n".join(output))  # Display everything on the screen

        # Clear the output list after writing/printing for the next command
        output.clear()


def main():
    """Main function for the command_master script."""
    logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

    # Parse arguments
    args = parse_arguments()

    # Read devices and commands from the YAML file
    devices, output_file = read_yaml_commands(args.commands)

    # If no output file is specified in the YAML, use a default log file name
    if not output_file:
        current_time = datetime.now().strftime('%Y-%m-%d_%H-%M-%S')
        output_file = f"log_{current_time}.txt"

    # Open the log file for writing (overwriting any existing content)
    with open(output_file, 'w') as log_file:
        # TODO: Write file header

        for device_info, commands in devices:  # Unpack the tuple here
            output = []
            ip = device_info['ip']
            logging.info(f"Connecting to {ip}...")

            # Establish SSH connection
            connection = establish_ssh_connection(device_info)

            if connection:
                # Execute commands and write the output to the log file
                # Write device ip address into the file
                logging.info(f"Collecting information from {ip}...")
                output.append('\n' + '=' * 80 + '\n')
                output.append(f" Device: {ip}\n")
                output.append('=' * 80 + '\n')

                log_file.write("\n".join(output))
                log_file.flush()  # Ensure data is written to the file

                # print on the screen the device name
                print("\n".join(output))

                execute_commands(connection, commands, log_file)
                connection.disconnect()
            else:
                logging.error(f"| Failed to connect to {ip}")

        output.append('\n' + '*' * 80)
        output.append("*  END OF DATA COLLECTION")
        output.append('*' * 80)

        log_file.write("\n".join(output))
        log_file.flush()  # Ensure data is written to the file

        # print on the screen the device name
        print("\n".join(output))

    logging.info(f"All commands executed. Output saved to {output_file}")


if __name__ == "__main__":
    main()
