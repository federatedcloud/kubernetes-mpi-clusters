#!/bin/bash
RUNNAME=$1
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
# Uncomment to test from command line:
#git_image_tag

## Docker image tagging
NAME="nix_tf_kubernetes_image"
TAG=$(git_image_tag)
export NIX_K8_TF_IMAGE="${NAME}:${TAG}"
echo "NIX_K8_TF_IMAGE is $NIX_K8_TF_IMAGE"
docker build -t "$NIX_K8_TF_IMAGE" -f Dockerfile .

docker stop tf_kubernetes_container
docker rm -f tf_kubernetes_container
docker run --name tf_kubernetes_container $NIX_K8_TF_IMAGE sleep 10000 &
sleep 5
docker exec -t tf_kubernetes_container nix-shell /home/nixuser/nix --run "/home/nixuser/nix/run.sh"
docker cp tf_kubernetes_container:/home/nixuser/results.txt hpl-results/${RUNNAME}.txt
