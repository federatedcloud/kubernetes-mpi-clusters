#!/bin/bash

## Controls building the Dockerfile, starting the container, and extracting results when finished.

## Forces giving each run a name to avoid writing over previous results
RUNNAME=$1
if [ ! -z ${RUNNAME} ]
then
  ## Append testing for uncommitted changes
  git_image_tag()
  {
    local commit
    commit=$(git rev-parse --verify HEAD)
    local tag="$commit"
    if [ ! -z "$(git status --porcelain)" ]; then
      tag="${commit}_testing"
    fi
    
    echo "$tag"
  }
  ## Remove and replace terraform service account
  az ad sp delete \
    --id=$(az ad sp list --query "[?appDisplayName=='tf-kubernetes-sp'].appId" -o tsv)
  SUBSCRIPTION_ID=$(az account list --query "[?isDefault].id" -o tsv)
  az ad sp create-for-rbac --name tf-kubernetes-sp --role="Contributor" \
    --scopes="/subscriptions/${SUBSCRIPTION_ID}" \
    | sed -e "s/displayName/subscriptionId/" -e "s/tf-kubernetes-sp/${SUBSCRIPTION_ID}/" -e "4d" \
    > tf-kubernetes/sp-cred.json
  ## Docker image tagging
  NAME="nix_tf_kubernetes_image_aks"
  TAG=$(git_image_tag)
  export NIX_K8_TF_IMAGE="${NAME}:${TAG}"
  echo "NIX_K8_TF_IMAGE is $NIX_K8_TF_IMAGE"
  docker build -t "$NIX_K8_TF_IMAGE" -f Dockerfile .
  ## Remove any old versions of the container to avoid conflicts
  docker stop tf_kubernetes_container_aks
  docker rm -f tf_kubernetes_container_aks
  ## Start the container, but have it sleep so we can `docker exec` into it if necessary
  docker run --name tf_kubernetes_container_aks $NIX_K8_TF_IMAGE sleep 100000 &
  #sleep 5
  ## Run terraform-kubernetes and copy out the results.
  #docker exec -t tf_kubernetes_container_aks nix-shell /home/nixuser/nix --run "/home/nixuser/nix/run.sh"
  #docker cp tf_kubernetes_container_aks:/home/nixuser/results.txt results/${RUNNAME}.txt
else
  echo Please title run
fi