#!/bin/bash

IP_S=$1

sudo apt update -y && sudo apt upgrade -y
sudo apt install -y net-tools

BASHRC_FILE="/home/vagrant/.bashrc"

FLANNEL_IFACE=$(ip -o -4 addr list | awk '$4 ~ /^192\.168\.56\./ {print $2}')

mkdir -p /vagrant/.config

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --node-name muguveliS --flannel-iface=$FLANNEL_IFACE --write-kubeconfig-mode 644" sh -

sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/.config/
sudo cp /etc/rancher/k3s/k3s.yaml /vagrant/.config

echo "alias k='kubectl'" >> "$BASHRC_FILE"
source "$BASHRC_FILE"
