cd $HOME/tf-kubernetes
#Create cluster, nodes
terraform init
terraform apply --auto-approve
#Connect to deploy kubernetes resources
GCREDENTIALS_PATH=$(echo var.google_credentials | terraform console)
gcloud auth activate-service-account --key-file=$GCREDENTIALS_PATH
gcloud container clusters get-credentials $(terraform output cluster_name) \
	--region $(terraform output region) \
	--project $(terraform output project_id)
#Create namespace
mv staging/namespace.tf .
terraform apply --auto-approve
#Add service account, clusterrole, clusterrolebinding
mv staging/mpi-operator.tf .
terraform apply --auto-approve
#Add mpijob crd and deployment using kubernetes-alpha provider
mv staging/mpijob-crd.tf .
terraform apply --auto-approve
#Add hpl-benchmarks MPIJob
mv staging/hpl-benchmarks.tf .
terraform apply --auto-approve
sleep 120
CONTAINER_NAME=$(echo var.container_name | terraform console)
kubectl cp HPL.dat ${CONTAINER_NAME}-worker-0:/home/nixuser
kubectl logs -f $(kubectl get pods -l mpi_job_name=${CONTAINER_NAME},mpi_role_type=launcher -o name) > /home/nixuser/results.txt
