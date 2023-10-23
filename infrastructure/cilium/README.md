# Description

This Kustomization is responsible for managing the Cilium installation in the cluster. By the point Flux gets to the reconciliation, the cluster will already have Cilium installed _with the same values_ as defined here. This makes it possible for Flux to transparently take over the management of Cilium.


# Hassle

Cilium _really_ does not want to be installed into any other namespace than `kube-system`. This is fine and makes sense for most of its parts, but moving Hubble UI into its own separate namespace would be really nice. It would allow automatic Linkerd proxy injection, increasing observability in `linkerd-viz`.
