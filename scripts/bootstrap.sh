#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# Start registry caches
podman-compose up -d

# Reset kind cluster
systemd-run --scope --user --property=Delegate=yes kind delete cluster --name ripple --kubeconfig "${KUBECONFIG}"
systemd-run --scope --user --property=Delegate=yes kind create cluster --config kind-config.yaml --kubeconfig "${KUBECONFIG}"

# Install Gateway API CRDs
kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd/experimental?ref=444631bfe06f3bcca5d0eadf1857eac1d369421d" | kubectl apply -f -;

# Now, we can bootstrap Flux
flux bootstrap github --token-auth --owner=ripple-transfer --repository=ripple-infra --branch master --path=clusters/dev

# And create the age secret so Flux can use it to decrypt encrypted YAML files. This is done after Flux,
# because the flux's namespace is only created in the previous step
cat ./.cert/age.agekey | kubectl create secret generic sops-age --namespace flux-infrastructure --from-file=age.agekey=/dev/stdin
