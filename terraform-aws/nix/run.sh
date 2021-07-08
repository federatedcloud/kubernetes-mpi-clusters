#!/nix/store/f475vzr63m77nfww608dni9385ahpvl1-nix-2.3.12/bin/nix-shell
## Creates the cluster and runs the provided MPIJob
cd $HOME/tf-kubernetes

csv=$(cat terraform.tfvars | grep aws_credentials | cut -d "=" -f 2 | xargs)
aws configure import --csv file://${csv}

echo "Creating network, cluster, nodes"
terraform init
terraform apply --auto-approve

## Connects Kubernetes to the cluster
sleep 10
aws eks update-kubeconfig --region $(terraform output -raw region) \
	--name $(terraform output -raw cluster_name) \
	--profile $(terraform output -raw profile)

echo "Creating namespace, service account, clusterrole, clusterrolebinding,"
echo "mpijob crd, deployment, and configmaps"
cp staging/mpi-operator.tf .
cp staging/aws-auth-map.tf .
terraform apply --auto-approve
echo "Adding MPIJob"
#cp staging/mpijob.tf .
#terraform apply --auto-approve

#echo "Running MPIJob"
#MPIJOB_NAME=$(terraform output -raw container_name)
#source ../nix/wait.sh ${MPIJOB_NAME}-launcher
#kubectl logs -f ${MPIJOB_NAME}-launcher -n mpi-operator 2>&1 | tee /home/nixuser/results.txt
