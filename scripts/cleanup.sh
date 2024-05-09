#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

systemd-run --scope --user --property=Delegate=yes kind delete cluster --name ripple --kubeconfig "${KUBECONFIG}"
