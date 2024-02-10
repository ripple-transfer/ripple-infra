- Add separate Minio tenants where applicable
- Generate Minio secrets for each tenant, remove "reflector"
- Turn on Grafana Agent clustering
- Split Grafana/Agent/Tempo/Loki into separate namespaces
- Set up Kafka using Strimzi (with KRaft)
- generate GitOps secret
- Use Pyroscope for continous profiling

# Hassle

fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 512
