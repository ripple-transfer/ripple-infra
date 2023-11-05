#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

kind create cluster --config kind-config.yaml

# Install Cilium, so we have a CNI in the cluster. We use the same values file that will
# be loaded by Flux, so we can transfer ownership of this installation once Flux is bootstrapped
helm repo add cilium https://helm.cilium.io/
helm install cilium cilium/cilium --namespace kube-system -f ./infrastructure/networking/cilium/values.yaml
cilium status --wait

# Now, we can bootstrap Flux
flux bootstrap github --token-auth --owner=loom-lang --repository=loom-infra --branch master --path=clusters/dev

# And create the age secret so Flux can use it to decrypt encrypted YAML files. This is done after Flux,
# because the flux's namespace is only created in the previous step
cat ./.cert/age.agekey | kubectl create secret generic sops-age --namespace flux-infrastructure --from-file=age.agekey=/dev/stdin
