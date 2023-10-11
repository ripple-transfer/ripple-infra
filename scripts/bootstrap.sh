flux bootstrap github --token-auth --owner=loom-lang --repository=loom-infra --branch master --path=clusters/dev
cat ./.cert/age.agekey | kubectl create secret generic sops-age --namespace flux-system --from-file=age.agekey=/dev/stdin
