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
cp staging/namespace.tf .
terraform apply --auto-approve
echo "Adding service account, clusterrole, clusterrolebinding"
cp staging/mpi-operator.tf .
terraform apply --auto-approve
echo "Adding mpijob crd and deployment using kubernetes-alpha provider"
cp staging/mpijob-crd.tf .
terraform apply --auto-approve
echo "Adding MPIJob"
cp staging/mpijob.tf .
terraform apply --auto-approve
echo "Waiting for pods to start"
MPIJOB_NAME=$(echo var.container_name | terraform console)
POD_NAME=${MPIJOB_NAME}-worker-0
#kubectl wait --for=condition=Ready pod/${POD_NAME} --timeout=300s
source ../nix/wait.sh pod/${POD_NAME}
kubectl cp ../mpi-files/* ${POD_NAME}:/home/nixuser
echo "Running MPIJob"
LAUNCHER=$(kubectl get pods -l mpi_job_name=${MPIJOB_NAME},mpi_role_type=launcher -o name)
source ../nix/wait.sh ${LAUNCHER}
kubectl logs -f ${LAUNCHER} > /home/nixuser/results.txt
