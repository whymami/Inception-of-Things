#!/bin/bash
SERVER_IP=$1
SERVER_PORT=6443
SERVER_URL="https://${SERVER_IP}:${SERVER_PORT}"
K3S_TOKEN_FILE="/vagrant/.config/my_token"
FLANNEL_IFACE=$(ip -o -4 addr list | awk '$4 ~ /^192\.168\.56\./ {print $2}')



curl -sfL https://get.k3s.io | K3S_URL=${SERVER_URL} K3S_TOKEN_FILE=${K3S_TOKEN_FILE}  "--flannel-iface=${FLANNEL_IFACE}" sh - && echo "K3s Agent is Running"
sudo rm -rf /vagrant/.config
sudo apt install -y net-tools > /dev/null