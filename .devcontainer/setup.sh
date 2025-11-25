#!/bin/bash
set -e

echo "Updating system..."
sudo apt update -y

echo "Installing base tools..."
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common \
    jq \
    git \
    make

###################################################
# Install Docker (NOT using any devcontainer feature)
###################################################
echo "Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Add VSCode user to docker group
sudo usermod -aG docker vscode
sudo systemctl enable docker
sudo systemctl restart docker

###################################################
# Install kubectl
###################################################
echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

###################################################
# Install helm
###################################################
echo "Installing Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

###################################################
# Install k3d
###################################################
echo "Installing k3d..."
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

###################################################
# Create Kubernetes cluster
###################################################
echo "Creating K3d cluster..."
k3d cluster create iotops --servers 1 --agents 2 --port "8081:80@loadbalancer"

###################################################
# Install Azure CLI
###################################################
echo "Installing Azure CLI..."
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

###################################################
# Install Azure IoT Ops CLI extension
###################################################
echo "Installing azure-iot-ops CLI extension..."
az extension add --upgrade --name azure-iot-ops

echo "Setup completed successfully!"
