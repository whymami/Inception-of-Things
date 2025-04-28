#!/bin/bash

SERVER_IP=$1
SERVER_PORT=6443
SERVER_URL="https://${SERVER_IP}:${SERVER_PORT}"

K3S_TOKEN_FILE="/vagrant/.config/node-token"

FLANNEL_IFACE=$(ip -o -4 addr list | awk '$4 ~ /^192\.168\.56\./ {print $2}')

curl -sfL https://get.k3s.io | K3S_URL=$SERVER_URL K3S_TOKEN=$(cat $K3S_TOKEN_FILE) INSTALL_K3S_EXEC="--node-name muguveliSW --flannel-iface=${FLANNEL_IFACE}" sh -
