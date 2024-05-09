# Description

Ripple is a toy implementation emulating cross-border payments, without the actual integration with the financial system. This repository contains the infrastructure, in which the whole project is going to run.

# Requirements

- Relatively recent Linux distribution
  - When using WSL2, you will need to build a custom kernel following [this guide](https://wsl.dev/wslcilium/)
- Suitable container engine: [Set up Rootless Podman](https://wiki.archlinux.org/title/Podman)
- Kubernetes cluster: the automated bootstrap uses [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- One domain name, preferably using a registrar with [cert-manager DNS01 integration](https://cert-manager.io/docs/configuration/acme/dns01/)
- [Mozilla SOPS](https://github.com/getsops/sops) and [age](https://github.com/FiloSottile/age) for secret encryption

# Preparations

## Updating secrets
Secrets in this repository are encrypted using an `age` private/public key pair, which means that bootstrapping will not work out of the box.

To set up your own encryption keys, first generate your own `age` key by running:

```bash
age-keygen -o .cert/age.agekey
```

Update the public key in the `.sops.yaml` file. Finally, re-encrypt the following secrets using your own values:

- `infrastructure/ingress/cloudflare-api-key.yaml`
- `infrastructure/minio/access-key.yaml`

### Example

1. Create the unencrypted version of your Kubernetes secret

```yaml
apiVersion: v1
kind: Secret
metadata:
    name: cloudflare-api-key-secret
    namespace: ingress
data:
    api-key: <my-secret-api-key>

```

2. Encrypt the file using SOPS

```bash
sops -e cloudflare-api-key.yaml | tee access-key.enc.yaml
```

3. Remove the unencerypted version of the secret

## Updating domain names

The project is set up to use the `ripple-transfer.dev` domain name. To use a different one, you can just do a search & replace for the domain and replace it with your own.

To issue certificates for your own domain, make sure to update the ACME issuer under `infrastructure/ingress/letsencrypt-issuer.yaml` to use your own provider's DNS01 setup.

## Updating load balancer IPs

The project uses MetalLB as a load balancer. We need to provide it an IP address range it can use. As explained in the [kind documentation](https://kind.sigs.k8s.io/docs/user/loadbalancer/), this has to be on the network created by podman. You can set up podman to use certain IP subnet pools when creating the networks in `/etc/containers/containers.conf` by adding:

```conf
default_subnet_pools = [
  {"base" = "10.89.0.0/16", "size" = 16},
  {"base" = "10.90.0.0/15", "size" = 24},
  {"base" = "10.92.0.0/14", "size" = 24},
  {"base" = "10.96.0.0/11", "size" = 24},
  {"base" = "10.128.0.0/9", "size" = 24},
]
```

You can also just create a dedicated kind network with the subnet you want to use. In either case, update:

- `infrastructure/metallb/metallb-config.yaml` to assign a range of IP addresses to the load balancer IP pool
- `infrastructure/ingress/infra/gateway.yaml` to set the preferred IP for the main ingress

# Setup

## Bootstrapping

A completely new Kubernetes cluster can be bootstrapped by running:

```bash
./scripts/bootstrap.sh
```

This will create a new Kind cluster with one control plane and two worker nodes. It also bootstraps Flux and sets up SOPS support.

## Flux reconciliation

After the bootstrap is complete, Flux will take over the management of the cluster, bringing all defined infrastructure up to date.

# Components

The individual components and technologies used are described in the respective README files.

- Networking
- Utilities
- Storage
- Monitoring
- Ingress

# Useful tips

## Finding interesting things

Search for `# Hassle` in the codebase to see the parts that were particularly annoying or tricky to set up, either due to component interactions or a lack of documentation.

## Easy local development

### Access services

To access services exposed by the ingress, you can set up `dnsmasq` on the host machine to resolve `*.ripple-transfer.dev` (or your equivalent) to the external IP address of the ingress `LoadBalancer`.

Install `dnsmasq` and add a new configuration under `/etc/dnsmasq.d/dev-domains.conf`:

```conf
address=/ripple-transfer.dev/<external IP>
```

Since the project is normally run using rootless podman, you need to start your browser in the netns that is used to set up the `podman` network. You can do this by:

```bash
podman unshare --rootless-netns
firefox-developer-edition
# Access services normally
```

If you get certificate errors, you can add the Let's Encrypt Staging Certificates to the trusted CAs of your browser **but please note** that this is very insecure, so make sure to use a separate browser for testing if you decide to do this.

#### WSL Proxying

If you are using WSL and want to load the pages on the host Windows machine, you also need to set up a reverse proxy on the Linux machine that forwards incoming WSL requests to the load balancer's external IP. You can do so by:

1. Installing `nginx`
2. Disabling active sites by deleting the symlinks from `/etc/nginx/sites-enabled`
3. Adding a new `stream` block in `/etc/nginx/nginx.conf` that forwards all HTTPS traffic to the load balancer.

```conf
stream {
  server {
    listen     443;
    proxy_pass <external IP>:443;
  }
}
```

Since `dnsmasq` does not work on Windows, you'll need to resolve the individual domain names to your WSL2 instance's IP address.

To get the WSL IP, run the following command in PowerShell:

```ps
wsl hostname -I | select { $_.split()[0] }
```

Then edit `%SystemRoot%\System32\drivers\etc\hosts`:

```
<WSL IP address> gitops.ripple-transfer.dev
<WSL IP address> k8s.ripple-transfer.dev
<WSL IP address> grafana.ripple-transfer.dev
<WSL IP address> minio.ripple-transfer.dev
```


