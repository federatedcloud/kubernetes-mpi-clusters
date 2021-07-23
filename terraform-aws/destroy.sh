#!/bin/bash
## Destroys the resources provisioned by terraform

docker exec -t tf_kubernetes_container_aws nix-shell --run 'cd ~/tf-kubernetes; terraform destroy --auto-approve'
docker stop tf_kubernetes_container_aws
