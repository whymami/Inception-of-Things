#!/bin/bash

SERVER_IP=$1

sudo apt update -y && sudo apt upgrade -y
sudo apt install -y net-tools curl

BASHRC_FILE="/home/vagrant/.bashrc"

FLANNEL_IFACE=$(ip -o -4 addr list | awk '$4 ~ /^192\.168\.56\./ {print $2}')

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--bind-address=$SERVER_IP --flannel-iface=${FLANNEL_IFACE}" sh - && echo "K3s installed successfully"

echo "alias k='kubectl'" >> "$BASHRC_FILE"

# 'if' kontrolü burada doğru bir şekilde bitirilmeli
if ! command -v kubectl &> /dev/null; then
    echo "K3s installation failed. Please check the installation."
    exit 1
else
    echo "K3s installation successful"
    source "$BASHRC_FILE"
    kubectl apply -n kube-system -f /vagrant/apps/app-one/deployment.yaml
    kubectl apply -n kube-system -f /vagrant/apps/app-two/deployment.yaml
    kubectl apply -n kube-system -f /vagrant/apps/app-three/deployment.yaml
    kubectl apply -n kube-system -f /vagrant/apps/ingress/ingress.yaml
fi

echo "K3s installation completed successfully."
