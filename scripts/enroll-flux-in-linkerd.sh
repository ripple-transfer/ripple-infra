#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

kubectl rollout restart deployment -n flux-system
