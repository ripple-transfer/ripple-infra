#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# Setting up the single-node cluster
if sudo k0s status &> /dev/null; then
    echo "Stopping k0s..."
    sudo k0s stop
    echo "Resetting k0s..."
    sudo k0s reset
else
    echo "k0s is not running. Skipping stop and reset."
fi

echo "Installing and starting k0s..."
sudo k0s install controller --single --config k0s.yaml
sudo k0s start

# Wait for k0s to become ready
until sudo k0s status; do echo "Waiting for k0s to become ready..."; sleep 2; done

# Set up config file for KUBECONFIG env variable
mkdir -p ~/.kube/
sudo k0s kubeconfig admin >| ~/.kube/config
chmod 600 ~/.kube/config

# Install Gateway API CRDs before Cilium, so we can immediately enable the Gateway API
kubectl apply -k ./infrastructure/networking/gateway-api

# Install Cilium, so we have a CNI in the cluster. We use the same values file that will
# be loaded by Flux, so we can transfer ownership of this installation once Flux is bootstrapped
helm repo add cilium https://helm.cilium.io/
helm install cilium cilium/cilium --namespace kube-system --version="1.15.0-rc.1" -f ./infrastructure/networking/cilium/values.yaml
cilium status --wait

# Now, we can bootstrap Flux
flux bootstrap github --token-auth --owner=ripple-transfer --repository=ripple-infra --branch master --path=clusters/dev

# And create the age secret so Flux can use it to decrypt encrypted YAML files. This is done after Flux,
# because the flux's namespace is only created in the previous step
cat ./.cert/age.agekey | kubectl create secret generic sops-age --namespace flux-infrastructure --from-file=age.agekey=/dev/stdin
