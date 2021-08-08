To use build.sh, you must first be logged in on the azure cli. It will create a new service principle whose credentials will be added to the Azure Active Directory that you are working in. These credentials will be stored in a json file inside the `tf_kubernetes_aks` container for terraform and kubernetes to use.

The current setup creates a resource group and the basic components of a cluster, included a VPC network, subnet, cluster, and a few other components. It is currently untested, but likely not far from being functional.

In order to use mpi-operator, the resources from staging in another directory such as terraform-aws or terraform-gcp can be copied over directly.

In order to run an nfs server, please refer to the kubernetes nfs repository and look at the persistent volume for an Azure Disk in order to create the correct resource.
