echo "Connecting to gcp to deploy kubernetes resources"
if [ $(echo var.zonal_cluster | terraform console) == "true" ]
then
	LOCATION="--zone $(terraform output -raw zone)"
else
	LOCATION="--region $(terraform output -raw region)"
fi
gcloud auth activate-service-account \
	--key-file=$(terraform output -raw google_credentials_file)
gcloud container clusters get-credentials $(terraform output -raw cluster_name) \
	${LOCATION} \
	--project $(terraform output -raw project_id)
