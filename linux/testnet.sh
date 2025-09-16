#!/bin/bash
# name: jacob
# student number: 041156249
# purpose: summarize network information
# date: 12-Sept-2025

# section 1: service status
echo "=== Service Status ==="
echo "network manager service status:" $(systemctl is-active NetworkManager)
echo "firewalld service status:" $(systemctl is-active firewalld)
echo "selinux status:" $(getenforce 2>/dev/null || echo "not installed")
# section 2: network interfaces
echo "=== Network Information ==="
echo "red interface (ens192) ip:" $(ip -4 addr show ens192 2>/dev/null | awk '/inet /{print $2}' || echo "not found")
echo "blue interface (ens160) ip:" $(ip -4 addr show ens160 2>/dev/null | awk '/inet /{print $2}' || echo "not found")
echo "dns servers:" $(nmcli dev show | grep 'IP4.DNS' | awk '{print $2}' | paste -sd ', ')
echo "hostname resolution:" $(cat /etc/resolv.conf | grep 'nameserver' | awk '{print $2}' | paste -sd ', ')
echo "hosts file entries:"
cat /etc/hosts | tail -n +3
echo "default gateway:" $(ip route | awk '/default/ {print $3}')
# section 3: connectivity tests
echo "=== Connectivity Tests ==="
CLIENT_IP="172.16.31.48" # client ip address
echo "ping to google (8.8.8.8):" $(ping -c 1 -W 1 8.8.8.8 &>/dev/null && echo "success" || echo "failed")
echo "ping to client ($CLIENT_IP):" $(ping -c 1 -W 1 "$CLIENT_IP" &>/dev/null && echo "success" || echo "failed")
GATEWAY_IP=$(ip route | awk '/default/ {print $3}')
echo "ping to default gateway ($GATEWAY_IP):" $(ping -c 1 -W 1 "$GATEWAY_IP" &>/dev/null && echo "success" || echo "failed")
echo "=== End of Script ==="