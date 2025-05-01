# Add Docker's official GPG key:
sudo apt-get update -y
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings -y
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y

# Install Docker Engine
sudo apt-get install docker docker-compose docker.io -y #docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Kubectl is downloaded
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install K3D
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
sleep 5

# Set up cluster with K3D
sudo k3d cluster create mycluster

# Kubectl downloaded and configurate
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Kubeconfig put in ~/.kube for kubectl
sudo mkdir ~/.kube
sudo k3d kubeconfig get mycluster > ~/.kube/config
chmod 600 ~/.kube/config
export KUBECONFIG=~/.kube/config

# Create two namespace, one of them for ArgoCD, another one is Application
kubectl create namespace argocd
kubectl create namespace dev

# ArgoCD CRD is downloaded
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# wait to be online ArgoCd
kubectl wait --for=condition=ready pod --all -n argocd --timeout=300s

# run argoCD.yaml
kubectl apply -f /vagrant/confs/argoCD.yaml

# argoCD password
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode > password.txt

# argoCD reach monitoring
kubectl port-forward svc/argocd-server -n argocd 8080:443 --address 0.0.0.0