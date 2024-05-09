#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

echo "Installing kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

echo "Installing Docker"
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu mantic stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install Docker
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Use docker commands without root
sudo usermod -aG docker $USER
newgrp docker

# Start Docker automatically
sudo systemctl enable --now docker.service
sudo systemctl enable --now containerd.service

echo "Installing sops"
SOPS_LATEST_VERSION=$(curl -Ls "https://api.github.com/repos/mozilla/sops/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
echo "Latest version: ${SOPS_LATEST_VERSION}"
curl -Lo sops.deb "https://github.com/mozilla/sops/releases/latest/download/sops_${SOPS_LATEST_VERSION}_amd64.deb"
sudo apt --fix-broken install ./sops.deb
rm sops.deb

echo "Installing age"
sudo apt install age

echo "Installing Helm"
curl -s https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "Installing Flux CLI"
curl -s https://fluxcd.io/install.sh | sudo bash

# kind
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.21.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
