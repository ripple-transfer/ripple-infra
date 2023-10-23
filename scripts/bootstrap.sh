#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

kind create cluster --config kind-config.yaml
helm repo add cilium https://helm.cilium.io/
helm install cilium cilium/cilium --namespace kube-system -f ./infrastructure/cilium/values.yaml
cilium status --wait
flux bootstrap github --token-auth --owner=loom-lang --repository=loom-infra --branch master --path=clusters/dev
cat ./.cert/age.agekey | kubectl create secret generic sops-age --namespace flux-system --from-file=age.agekey=/dev/stdin
