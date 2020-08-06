Contents:
 - [cp-all.sh](cp-all.sh): Injects contents of [mpi-files](../mpi-files/) into worker node 0
 - [default.nix](default.nix): Nix package derivation for deploying terraform-kubernetes
 - [rerun.sh](rerun.sh): Used with existing cluster, but variation in parameters
 - [run.sh](run.sh): Run on the base container when setting up cluster and for first run
 - [wait.sh](wait.sh): Waits for active container in node to be running
