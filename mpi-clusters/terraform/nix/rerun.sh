cd $HOME/tf-kubernetes
rm mpijob.tf
echo "Removing old mpijob"
terraform apply --auto-approve
kubectl wait --for=delete pods --all=true --timeout=120s
cp staging/mpijob.tf .
terraform apply --auto-approve
echo "Wating for pods to start"
MPIJOB_NAME=$(echo var.container_name | terraform console)
POD_NAME=${MPIJOB_NAME}-worker-0
source ../nix/wait.sh pod/${POD_NAME}
kubectl cp ../mpi-files/* ${POD_NAME}:/home/nixuser
echo "Running MPIJob"
LAUNCHER=$(kubectl get pods -l mpi_job_name=${MPIJOB_NAME},mpi_role_type=launcher -o name)
source ../nix/wait.sh ${LAUNCHER}
kubectl logs -f ${LAUNCHER} > /home/nixuser/results.txt
