#!/nix/store/f475vzr63m77nfww608dni9385ahpvl1-nix-2.3.12/bin/nix-shell

echo "Connecting to aws to deploy kubernetes resources"
## Connects the service account to this container
aws configure import --csv file://$(terraform output -raw aws_credentials)

## Connects this container to the cluster

aws eks --region $(terraform output -raw region) \
	update-kubeconfig \
	--name $(terraform output -raw cluster_name)
