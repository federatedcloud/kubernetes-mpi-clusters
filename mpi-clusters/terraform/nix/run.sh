cd $HOME/tf-kubernetes

echo "Creating cluster, nodes"
terraform init
terraform apply --auto-approve

sleep 10
source ../nix/gcloud-authn.sh

echo "Creating namespace, service account, clusterrole, clusterrolebinding, mpijob crd, deployment"
cp staging/mpi-operator.tf .
terraform apply --auto-approve
echo "Adding MPIJob"
cp staging/mpijob.tf .
terraform apply --auto-approve

echo "Waiting for pods to start"
MPIJOB_NAME=$(terraform output -raw container_name)
sleep 1
source ../nix/wait.sh pod/${MPIJOB_NAME}-worker-0
source ../nix/cp-all.sh ../mpi-files ${MPIJOB_NAME}-worker-0

echo "Running MPIJob"
source ../nix/wait.sh pod/${MPIJOB_NAME}-launcher
kubectl logs -f ${MPIJOB_NAME}-launcher -n mpi-operator > /home/nixuser/results.txt
