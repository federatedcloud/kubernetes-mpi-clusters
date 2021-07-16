#!/nix/store/d48wjj8swi562h389yii2jyhm07lmss0-nix-2.3.6/bin/nix-shell
## Creates the cluster and runs the provided MPIJob
cd $HOME/tf-kubernetes

echo "Creating cluster, nodes"
terraform init
terraform apply --auto-approve

sleep 10
echo "Connecting to gcp to deploy kubernetes resources"
## Check for regional/zonal cluster to authenticate properly
if [ $(echo var.zonal_cluster | terraform console) == "true" ]
then
	LOCATION="--zone $(terraform output -raw zone)"
else
	LOCATION="--region $(terraform output -raw region)"
fi

## Connects service account to this container
gcloud auth activate-service-account \
	--key-file=$(terraform output -raw google_credentials_file)

## Connects this container to the cluster
gcloud container clusters get-credentials $(terraform output -raw cluster_name) \
	${LOCATION} \
	--project $(terraform output -raw project_id)

echo "Creating namespace, service account, clusterrole, clusterrolebinding,"
echo "mpijob crd, deployment, and configmap"
cp staging/mpi-operator.tf .
terraform apply --auto-approve
kubectl config set-context $(kubectl config current-context) --namespace=mpi-operator
echo "Adding MPIJob"
cp staging/mpijob.tf .
terraform apply --auto-approve

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
