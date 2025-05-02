#!/bin/bash

# Define colors
GREEN=$(tput setaf 2)        # Green text
YELLOW=$(tput setaf 3)       # Yellow text
RED=$(tput setaf 1)          # Red text
BOLD=$(tput bold)            # Bold text
RESET=$(tput sgr0)           # Reset formatting

# Add Docker's official GPG key:
echo "${BOLD}${YELLOW}[!] Adding Docker's official GPG key...${RESET}"
sudo apt update -y > /dev/null 2>&1
sudo apt install ca-certificates curl -y > /dev/null 2>&1
sudo install -m 0755 -d /etc/apt/keyrings > /dev/null 2>&1
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc > /dev/null 2>&1
sudo chmod 644 /etc/apt/keyrings/docker.asc > /dev/null 2>&1

# Add the repository to Apt sources:
echo "${BOLD}${YELLOW}[!] Adding Docker repository to Apt sources...${RESET}"
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y > /dev/null 2>&1

# Install Docker Engine
echo "${BOLD}${YELLOW}[!] Installing Docker Engine...${RESET}"
sudo apt install docker docker-compose docker.io -y > /dev/null 2>&1

# Kubectl is downloaded
echo "${BOLD}${YELLOW}[!] Downloading kubectl...${RESET}"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" > /dev/null 2>&1
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256" > /dev/null 2>&1

# Verify the kubectl binary
echo "${BOLD}${YELLOW}[!] Verifying kubectl binary...${RESET}"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check --status > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "${RED}Kubectl checksum mismatch!${RESET}"
    exit 1
fi

# Install kubectl
echo "${BOLD}${YELLOW}[!] Installing kubectl...${RESET}"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl > /dev/null 2>&1

# Install K3D
echo "${BOLD}${YELLOW}[!] Installing K3D...${RESET}"
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash > /dev/null 2>&1

# Wait for K3D installation to complete by checking if k3d command is available
while ! command -v k3d &> /dev/null; do
    echo "${YELLOW}Waiting for K3D installation to complete...${RESET}"
    sleep 1  # Short sleep to prevent excessive CPU usage
done

# Print success message in bold green when K3D is installed
echo "${BOLD}${GREEN}[!] K3D installation complete!${RESET}"

# Run start.sh if it exists
if [ -f "./start.sh" ]; then
    echo "${BOLD}${YELLOW}[!] Running start.sh...${RESET}"
    bash start.sh
else
    echo "${RED}start.sh not found!${RESET}"
    exit 1
fi
