Deploying MPI Clusters with Terraform/Ansible
---------------------------------------------
One way of running mpi jobs is "manually" with Terraform and Ansible. Here's a broad overview of how we do it in the [ansible-terraform repo](https://github.com/federatedcloud/ansible-terraform). Instructions for how to use that tool are given in their fullest detail in the [benchmarks](https://github.com/federatedcloud/ansible-terraform/benchmarks)

1. A docker container builds a nix environment that installs Terraform and Ansible
2. The container uses Terraform to create a public cloud network, a base instance, and all the protocols needed to manage traffic.
3. The base instance downloads all the tools necessary to run the your mpi application and creates the image it will run from via Ansible.
4. Terraform goes through a few steps enabling it to make duplicates of that base instance, then creates those duplicates with the networking information needed to run mpi jobs.
5. Terraform then has Ansible run the multivm mpi job.
6. Getting the results has not yet been automated. One option is detailed below for GCP:
  - Go to the Cloud Console > Compute Engine > VM instances > mpi-instance0.
  - Click ssh to connect to open a terminal connected to the vm in your brower.
  - You can now use `docker cp` and `scp` to transfer the files back to your machine.

MPI Clusters with Terraform/Kubernetes
--------------------------------------
Alternatively, we can use a Terraform/Kubernetes deployment. Currently, this relies on cutting edge tools including terraform's beta google provider and alpha kubernetes provider, as well as mpi-operator, a tool currently in development as part of Kubeflow. The current process is described below, and can be replicated with `source build.sh` provided that you are logged into your GCP account with gcloud and have the necessary IAM roles.

1. Terraform provisions a GCP VPC network and subnetwork for the cluster to operate on
2. Terraform creates a cluster and non-default node pool running kubernetes 1.17+ (required for alpha kubernetes provider)
3. gcloud connects kubernetes to the cluster, which in turn allows terraform to deploy resources to it.
4. Due to required server-side planning with the alpha kubernetes provider, [staging.tf](staging.tf) is copied to the work directory and the `mpi-operator` namespace is created.
5. The [mpi-operator.tf](./staging/mpi-operator.tf), the file describing the service account, cluster role, and cluster role binding are copied to the work directory and the corresponding resources are created.
6. Finally, the `mpijob` custom resource and the `mpi-operator` deployment are brought into the work directory via [mpijob_crd.tf](./staging/mpijob_crd.tf) and created.

This is currently a work in progress. Next steps include moving this setup into a Docker (Nix) setup and testing it with HPL benchmarks.
