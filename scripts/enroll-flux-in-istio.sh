#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

kubectl label namespace flux-system istio.io/dataplane-mode=ambient
