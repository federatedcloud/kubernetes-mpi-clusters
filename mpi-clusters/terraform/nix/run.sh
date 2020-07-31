cd $HOME/tf-kubernetes
echo "Creating cluster, nodes"
terraform init
terraform apply --auto-approve
echo "Connecting to gcp to deploy kubernetes resources"
GCREDENTIALS_PATH=$(echo var.google_credentials | terraform console)
gcloud auth activate-service-account --key-file=$GCREDENTIALS_PATH
gcloud container clusters get-credentials $(terraform output cluster_name) \
	--region $(terraform output region) \
	--project $(terraform output project_id)
echo "Creating namespace"
mv staging/namespace.tf .
terraform apply --auto-approve
echo "Adding service account, clusterrole, clusterrolebinding"
mv staging/mpi-operator.tf .
terraform apply --auto-approve
echo "Adding mpijob crd and deployment using kubernetes-alpha provider"
mv staging/mpijob-crd.tf .
terraform apply --auto-approve
echo "Adding hpl-benchmarks MPIJob"
mv staging/hpl-benchmarks.tf .
terraform apply --auto-approve
echo "Waiting for pods to start"
sleep 120
CONTAINER_NAME=$(echo var.container_name | terraform console)
kubectl cp HPL.dat ${CONTAINER_NAME}-worker-0:/home/nixuser
echo "Running HPL"
kubectl logs -f $(kubectl get pods -l mpi_job_name=${CONTAINER_NAME},mpi_role_type=launcher -o name) > /home/nixuser/results.txt
