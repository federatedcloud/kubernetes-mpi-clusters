#!/nix/store/d48wjj8swi562h389yii2jyhm07lmss0-nix-2.3.6/bin/nix-shell

echo "Connecting to gcp to deploy kubernetes resources"
## Check for regional/zonal cluster to authenticate properly
if [ $(echo var.zonal_cluster | terraform console) == "true" ]
then
	LOCATION="--zone $(terraform output -raw zone)"
else
	LOCATION="--region $(terraform output -raw region)"
fi

## Connects the service account to this container
gcloud auth activate-service-account \
	--key-file=$(terraform output -raw google_credentials_file)

## Connects this container to the cluster
gcloud container clusters get-credentials $(terraform output -raw cluster_name) \
	${LOCATION} \
	--project $(terraform output -raw project_id)
