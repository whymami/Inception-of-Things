#!/bin/bash
apt update && apt upgrade -y
apt install curl -y
apt install net-tools -y
mkdir -p ~/.kube
cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
chown $(whoami):$(whoami) ~/.kube/config
curl -sfL https://get.k3s.io | sh - && echo "K3s installed successfully"
kubectl get nodes
systemctl status k3s
