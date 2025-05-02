#!/bin/bash

# Define colors
GREEN=$(tput setaf 2)        # Green text
YELLOW=$(tput setaf 3)       # Yellow text
RED=$(tput setaf 1)          # Red text
BOLD=$(tput bold)            # Bold text
RESET=$(tput sgr0)           # Reset formatting

# Set up cluster with K3D
echo "${BOLD}${YELLOW}[!] Creating K3D cluster...${RESET}"
sudo k3d cluster create mycluster > /dev/null

# Kubeconfig setup
echo "${BOLD}${YELLOW}[!] Setting up kubeconfig...${RESET}"
sudo mkdir -p ~/.kube
sudo k3d kubeconfig get mycluster > ~/.kube/config 2>&1
chmod 600 ~/.kube/config
export KUBECONFIG=~/.kube/config

# Create namespaces
echo "${BOLD}${YELLOW}[!] Creating namespaces...${RESET}"
kubectl create namespace argocd > /dev/null
kubectl create namespace dev > /dev/null

# Install ArgoCD
echo "${BOLD}${YELLOW}[!] Installing ArgoCD...${RESET}"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml > /dev/null

# Wait for ArgoCD pods to be ready
echo "${BOLD}${YELLOW}[!] Waiting for ArgoCD pods to be ready...${RESET}"
kubectl wait --for=condition=ready pod --all -n argocd --timeout=600s > /dev/null
echo "${BOLD}${GREEN}[!] ArgoCD pods are ready!${RESET}"

# Apply ArgoCD configuration
echo "${BOLD}${YELLOW}[!] Applying ArgoCD configuration...${RESET}"
kubectl apply -n argocd -f ../confs/argocd.yaml > /dev/null

# Get ArgoCD admin password
echo "${BOLD}${YELLOW}[!] Getting ArgoCD admin password...${RESET}"
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode > password.txt
echo "${BOLD}${GREEN}[!] ArgoCD admin password saved to password.txt${RESET}"

# Deploy application and expose services
echo "${BOLD}${YELLOW}[!] Deploying application and exposing services...${RESET}"
kubectl apply -n dev -f ../confs/dev/will42-service.yaml
echo "${BOLD}${YELLOW}[!] Waiting for 10 seconds...${RESET}"

# Exposing ArgoCD and will42 services
echo "${BOLD}${YELLOW}[!] Exposing ArgoCD and will42 services...${RESET}"

# Port forwarding for ArgoCD service
kubectl port-forward svc/argocd-server -n argocd 8080:443 --address=0.0.0.0 & 
echo "${BOLD}${YELLOW}[!] Waiting for 10 seconds...${RESET}"

# Function to try port forwarding for will42 service until it works
while true; do
    kubectl port-forward svc/wil42-service -n dev 8888:8888 --address=0.0.0.0 &
    if [ $? -eq 0 ]; then
        echo "${BOLD}${GREEN}[!] Port-forwarding successful for wil42-service!${RESET}"
        break  # Exit the loop if port-forwarding was successful
    else
        echo "${BOLD}${RED}[!] Port-forwarding failed for wil42-service. Retrying...${RESET}"
        sleep 5  # Wait before retrying
    fi
done

echo "${BOLD}${GREEN}[!] Services are exposed!${RESET}"
