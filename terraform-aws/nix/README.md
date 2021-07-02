# Nix scripts
Contains scripts to run on the local container.

Contents:
 - [default.nix](default.nix): Nix package derivation for deploying terraform-kubernetes
 - [gcloud-authn.sh](gcloud-authn.sh): Connects Kubernetes to the GKE cluster
 - [rerun.sh](rerun.sh): Used with existing cluster, but variation in parameters
 - [run.sh](run.sh): Run on the base container when setting up cluster and for first run
 - [wait.sh](wait.sh): Waits for active container in node to be running
