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
	## Docker image tagging
	NAME="nix_tf_kubernetes_image_aws"
	TAG=$(git_image_tag)
	export NIX_K8_TF_IMAGE="${NAME}:${TAG}"
	echo "NIX_K8_TF_IMAGE is $NIX_K8_TF_IMAGE"
	docker build -t "$NIX_K8_TF_IMAGE" -f Dockerfile .
	## Remove any old versions of the container to avoid conflicts
	docker stop tf_kubernetes_container_aws
	docker rm -f tf_kubernetes_container_aws
	## Start the container, but just have it sleep so we can `docker exec` into it if necessary
	docker run --name tf_kubernetes_container_aws $NIX_K8_TF_IMAGE sleep 100000 &
	#sleep 5
	## Run terraform-kubernetes and copy out the results.
	#docker exec -t tf_kubernetes_container_aws nix-shell /home/nixuser/nix --run "/home/nixuser/nix/run.sh"
	#docker cp tf_kubernetes_container_aws:/home/nixuser/results.txt results/${RUNNAME}.txt
else
	echo Please title run
fi
