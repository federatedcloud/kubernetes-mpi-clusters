cd $HOME/tf-kubernetes

echo "Creating cluster, nodes"
terraform init
terraform apply --auto-approve

source ../nix/gcloud-authn.sh

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
source ../nix/wait.sh pod/${MPIJOB_NAME}-worker-0
source ../nix/cp-all.sh ../mpi-files ${MPIJOB_NAME}-worker-0

echo "Running MPIJob"
LAUNCHER=$(kubectl get pods -l mpi_job_name=${MPIJOB_NAME},mpi_role_type=launcher -o name)
source ../nix/wait.sh ${LAUNCHER}
kubectl logs -f ${LAUNCHER} > /home/nixuser/results.txt
