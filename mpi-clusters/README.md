The resources in this directory seek to guide the user in creating a Kubernetes cluster that leverages the utility of MPI in their work.

There are two tools, mpi-operator and kube-openmpi.

At this point, it will help to install `helm`. The easiest way is
```
$ sudo snap install helm --classic
```
Or
```
$ brew install helm
```
Alternatively, you can run
```
$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
$ chmod 700 get_helm.sh
$ ./get_helm.sh
```
or find a stable release by following the instructions [here](https://helm.sh/docs/intro/install/)

Also it may be good to start using a public cloud service. As Kubernetes was developed by Google, this guide will show you how to set up a GCP account. Note that they often provide $300 of cloud credits when you create an account which is easily enough to get started. More on that [here](PUBLICCLOUD.md)

Kube-openmpi
============
Repository is [here](https://github.com/everpeace/kube-openmpi/tree/master/chainermn-example)

Trying to run the example code raised numerous issues. See the following list compiled while trying to make it work.

List of Issues with `kube-openmpi` so far
 - Likely not useful long-term (appears to be depracated)
 - Some `helm` syntax has changed
   - Instead of `helm template ../chart --namespace $KUBE_NAMESPACE --name $MPI_CLUSTER_NAME ...` run `helm template $MPI_CLUSTER_NAME ../chart --namespace $KUBE_NAMESPACE ...`
 - Needed to create accounts file for processes to have the right permissions
   - Otherwise, master node gets stuck in crashloop
   - See [issue thread](https://github.com/everpeace/kube-openmpi/issues/24)
 - Warning with ssh-key on template generation
   - Unknown impact. [relevant issue thread](https://github.com/everpeace/kube-openmpi/issues/30) removed warning, but didn't make nodes run
 - Issue with given container
   - Running `kubectl get -n $KUBE_NAMESPACE pods` shows master node is on `Init 1/2`
   - Then `kubectl logs -n pods $KUBE_NAMESPACE $MPI-CLUSTER_NAME-master hostfile-initializer` gives the error
     ```
     kube-openmpi/utils/gen_hostfile.sh: line 1: can't open /kube-openmpi/generated/hostfile_new: no such file
     ```
 - Only appears to provide support for Ubuntu 16.04 applications
 - Requires applications be built using `everpeace/kube-openmpi` as a base image

As such, focus has moved to using mpi-operator.

MPI-Operator
============
Documentation provided at the [mpi-operator repo](https://github.com/kubeflow/mpi-operator)
 - There is now a working and fully documented set-up with terraform and mpi-operator in [terraform/](terraform)
 - It can also be deployed using .yaml files, provided that your cluster is running Kubernetes 1.17+
