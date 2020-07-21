#Create cluster, nodes
terraform init
terraform apply --auto-approve
#Connect to deploy kubernetes resources
gcloud container clusters get-credentials kubernetes-tf-cluster --region $(terraform output region) --project $(terraform output project_id)
#Create namespace
cp staging/namespace.tf .
terraform apply --auto-approve
#Add service account, clusterrole, clusterrolebinding
cp staging/mpi-operator.tf .
terraform apply --auto-approve
#Add mpijob crd and deployment using kubernetes-alpha provider
cp staging/mpijob-crd.tf .
terraform apply --auto-approve
