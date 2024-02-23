#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

sudo kind delete cluster --name ripple --kubeconfig "${KUBECONFIG}"
