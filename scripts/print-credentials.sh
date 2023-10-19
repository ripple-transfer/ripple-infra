echo "Minio: $(kubectl get secret -n minio minio-root -o jsonpath='{.data.root-user}' | base64 -d) / $(kubectl get secret -n minio minio-root -o jsonpath='{.data.root-password}' | base64 -d)"
echo "K8s dashboard: $(kubectl get secret -n kubernetes-dashboard dashboard-admin-token -o jsonpath='{.data.token}' | base64 -d)"
