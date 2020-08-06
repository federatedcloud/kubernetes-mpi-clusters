cd $HOME/tf-kubernetes

echo "Removing old mpijob"
rm mpijob.tf
terraform apply --auto-approve
kubectl wait --for=delete pods --all=true --timeout=300s

source ../nix/gcloud-authn.sh

echo "Creating new mpijob"
cp staging/mpijob.tf .
terraform apply --auto-approve

echo "Wating for pods to start"
MPIJOB_NAME=$(echo var.container_name | terraform console)
source ../nix/wait.sh pod/${MPIJOB_NAME}-worker-0
source ../nix/cp-all.sh ../mpi-files ${MPIJOB_NAME}-worker-0

echo "Running MPIJob"
LAUNCHER=$(kubectl get pods -l mpi_job_name=${MPIJOB_NAME},mpi_role_type=launcher -o name)
source ../nix/wait.sh ${LAUNCHER}
kubectl logs -f ${LAUNCHER} > /home/nixuser/results.txt
