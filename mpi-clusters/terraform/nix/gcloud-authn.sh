echo "Connecting to gcp to deploy kubernetes resources"
if [ $(echo var.zonal_cluster | terraform console) == "true" ]
then
	LOCATION="--zone $(terraform output zone)"
else
	LOCATION="--region $(terraform output region)"
fi
gcloud auth activate-service-account \
	--key-file=$(echo var.google_credentials | terraform console)
gcloud container clusters get-credentials $(terraform output cluster_name) \
	${LOCATION} \
	--project $(terraform output project_id)
