#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# Reset kind cluster
kind delete cluster --name ripple
kind create cluster --config kind-config.yaml

# Install Cilium, so we have a CNI in the cluster. We use the same values file that will
# be loaded by Flux, so we can transfer ownership of this installation once Flux is bootstrapped
helm repo add cilium https://helm.cilium.io/
helm repo update
helm install cilium cilium/cilium --version="1.15.x" --namespace="kube-system" -f ./infrastructure/networking/cilium/values.yaml
cilium status --wait

# Install Gateway API CRDs
kubectl apply -k ./infrastructure/networking/gateway-api-crds

# Now, we can bootstrap Flux
flux bootstrap github --token-auth --owner=ripple-transfer --repository=ripple-infra --branch master --path=clusters/dev

# And create the age secret so Flux can use it to decrypt encrypted YAML files. This is done after Flux,
# because the flux's namespace is only created in the previous step
cat ./.cert/age.agekey | kubectl create secret generic sops-age --namespace flux-infrastructure --from-file=age.agekey=/dev/stdin
