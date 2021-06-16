cd $HOME/tf-kubernetes
rm mpijob.tf
terraform apply -auto-approve
cp staging/mpijob.tf .
cp staging/mpi-operator.tf .
terraform apply -auto-approve

echo "Running MPIJob"
MPIJOB_NAME=$(terraform output -raw container_name)
source ../nix/wait.sh ${MPIJOB_NAME}-launcher
echo "Printing logs"
kubectl logs -f ${MPIJOB_NAME}-launcher -n mpi-operator 2>&1 | tee /home/nixuser/results.txt