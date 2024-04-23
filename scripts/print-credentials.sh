#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

MINIO_SA_TOKEN=$(kubectl -n minio get secret console-sa-secret -o jsonpath="{.data.token}" | base64 --decode)

echo "Minio: ${MINIO_SA_TOKEN}"
# echo "K8s dashboard: $(kubectl get secret -n kubernetes-dashboard dashboard-admin-token -o jsonpath='{.data.token}' | base64 -d)"
