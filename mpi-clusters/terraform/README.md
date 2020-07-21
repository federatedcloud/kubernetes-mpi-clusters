Deploying MPI Clusters with Terraform/Ansible
=============================================
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
