- Split Grafana/Agent/Tempo/Loki into separate namespaces
- Set up Kafka using Strimzi (with KRaft)
- Set up KNative
- Set up PostgreSQL vs CloudNativePG
- generate GitOps secret
- Use Pyroscope for continous profiling
- Grafana Data Source Config
  - Tempo Service Map
  - Link to logs metrics for Tempo
- Figure out Grafana dashboard imports
- Loki caching
- Come up with a custom operator + CRD that simplifies the deployment of KNative services
- Upgrade minio to v6
- Generate separate secrets for all Minio tenants
- Re-enable Grafana login
- Re-add Grafana multitenancy

# Hassle

fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 512
