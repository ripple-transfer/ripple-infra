- Set up Kafka using Strimzi (with KRaft)
- Set up KNative
- Set up PostgreSQL vs CloudNativePG
- generate GitOps secret
- Grafana Data Source Config
  - Tempo Service Map
- Loki caching
- Come up with a custom operator + CRD that simplifies the deployment of KNative services
- Generate separate secrets for all Minio tenants
- Re-enable Grafana login
- Re-add Grafana multitenancy
- Set up a new services repository
- Set up k8s dashboard
- https://istio.io/latest/docs/ops/best-practices/observability/
- Save pod name metrics
- Set up kiali auth
- Prometheus annotation metrics for pods are scraped as many times as the pods have ports, this is because istio doesn't have a pod container port exposed that matches their Prometheus setup (even though it still works)

# Hassle

fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 512
max-keys
max-key-bytes
