#!/nix/store/f475vzr63m77nfww608dni9385ahpvl1-nix-2.3.12/bin/nix-shell
## Creates the cluster and runs the provided MPIJob
cd $HOME/tf-kubernetes

terraform init
terraform refresh -target=var.aws_credentials -compact-warnings
aws configure import --csv file://$(terraform output -raw aws_credentials)

echo "Creating network, cluster, nodes"
terraform apply --auto-approve

## Connects Kubernetes to the cluster
sleep 10
aws eks update-kubeconfig --region $(terraform output -raw region) \
	--name $(terraform output -raw cluster_name) \
	--profile $(terraform output -raw profile)

## Add metrics logging
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

echo "Creating namespace, service account, clusterrole, clusterrolebinding,"
echo "mpijob crd, deployment, and configmaps"
cp staging/mpi-operator.tf .
cp staging/aws-auth-map.tf .
terraform apply --auto-approve

# Set default namespace to mpi-operator for ease of use
kubectl config set-context $(kubectl config current-context) --namespace=mpi-operator
kubectl apply -f ../nfs/
kubectl get svc
echo "Adding MPIJob"
#cp staging/mpijob.tf .
#terraform apply --auto-approve

#echo "Running MPIJob"
#LAUNCHER="$(terraform output -raw container_name)-launcher"
## Waits until the launcher pod has been created
#kubectl wait --for=condition=Ready pods $LAUNCHER --timeout=60s > /dev/null
## Waits until the container inside the launcher pod is running
#while [ $(kubectl get pods $LAUNCHER -o jsonpath={.status.phase}) != "Running" ]
#do
#	sleep 1
#done
#echo $LAUNCHER is ready
#kubectl logs -f $LAUNCHER 2>&1 | tee /home/nixuser/results.txt
