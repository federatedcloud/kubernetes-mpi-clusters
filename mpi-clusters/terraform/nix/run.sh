cd $HOME/tf-kubernetes

echo "Creating cluster, nodes"
terraform init
terraform apply --auto-approve

sleep 10
source ../nix/gcloud-authn.sh

echo "Creating namespace, service account, clusterrole, clusterrolebinding,"
echo "mpijob crd, deployment, and configmap"
cp staging/mpi-operator.tf .
terraform apply --auto-approve
echo "Adding MPIJob"
cp staging/mpijob.tf .
terraform apply --auto-approve

echo "Running MPIJob"
MPIJOB_NAME=$(terraform output -raw container_name)
source ../nix/wait.sh ${MPIJOB_NAME}-launcher
kubectl logs -f ${MPIJOB_NAME}-launcher -n mpi-operator 2>&1 | tee /home/nixuser/results.txt
