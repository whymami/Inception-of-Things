#!/bin/bash

sudo apt update
sudo apt install -y curl

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode=644" sh -

echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> $HOME/.bashrc
echo 'export PATH=$PATH:/usr/local/bin' >> $HOME/.bashrc

source $HOME/.bashrc


sudo kubectl apply -f /vagrant/confs/app-one.yaml > /dev/null
sudo kubectl wait deployment app-one --for condition=Available=True --timeout=-1s > /dev/null && echo "app-one deployed successfully"

sudo kubectl apply -f /vagrant/confs/app-two.yaml > /dev/null
sudo kubectl wait deployment app-two --for condition=Available=True --timeout=-1s > /dev/null && echo "app-two deployed successfully"

sudo kubectl apply -f /vagrant/confs/app-three.yaml > /dev/null
sudo kubectl wait deployment app-three --for condition=Available=True --timeout=-1s > /dev/null && echo "app-three deployed successfully"


sudo kubectl apply -f /vagrant/confs/ingress.yaml > /dev/null
while [ -z $external_ip ]; do echo "Waiting ingress...";
external_ip=$(sudo kubectl get ing iot-ingress --output="jsonpath={.status.loadBalancer.ingress[0].ip}");
[ -z "$external_ip" ] && sleep 10;
done;

sudo apt install net-tools -y