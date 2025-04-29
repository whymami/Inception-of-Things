#!/bin/bash

SERVER_IP=$1

#sudo apt update -y && sudo apt upgrade -y

BASHRC_FILE="/home/vagrant/.bashrc"

FLANNEL_IFACE=$(ip -o -4 addr list | awk '$4 ~ /^192\.168\.56\./ {print $2}')

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644" sh -

echo "alias k='kubectl'" >> "$BASHRC_FILE"

sleep 35


if ! command -v kubectl &> /dev/null; then
    echo "K3s installation failed. Please check the installation."
    exit 1
else
    echo "K3s installation successful"
    source "$BASHRC_FILE"
    
    # Kubeconfig dosyasını kopyala
    mkdir -p ~/.kube
    sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
    sudo chown vagrant:vagrant ~/.kube/config
    
    # Uygulamaları deploy et
    kubectl apply -f /vagrant/confs/app-one/deployment.yaml
    kubectl apply -f /vagrant/confs/app-two/deployment.yaml
    kubectl apply -f /vagrant/confs/app-three/deployment.yaml
    kubectl apply -f /vagrant/confs/network/ingress.yaml
fi

echo "K3s installation completed successfully."
