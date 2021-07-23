#!/nix/store/f475vzr63m77nfww608dni9385ahpvl1-nix-2.3.12/bin/nix-shell

## Removes old MPIJob and reapplies as terraform can't chane it in-place reliably
cd $HOME/tf-kubernetes
rm mpijob.tf
terraform apply -auto-approve

## Copies in new versions and applies
cp staging/mpijob.tf .
cp staging/mpi-operator.tf .
terraform apply -auto-approve

echo "Running MPIJob"
MPIJOB_NAME=$(terraform output -raw container_name)
source ../nix/wait.sh ${MPIJOB_NAME}-launcher
echo "Printing logs"
kubectl logs -f ${MPIJOB_NAME}-launcher -n mpi-operator 2>&1 | tee /home/nixuser/results.txt
