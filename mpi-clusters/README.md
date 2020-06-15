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

Trying to run the example code raisd numerous issues. See the following list compiled while trying to make it work.

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

MPI-Operator
============
Current progress:
 - Found [github repo](https://github.com/kubeflow/mpi-operator), downloaded with git clone
 - Created mpi-operator with `deploy/v1alpha2/mpi-operator.yaml`
 - Confirmed it is running with `kubectl get crd`
 - Tried running an example from `examples/horovod`
   - Built docker container with `docker build -t horovod:latest -f Dockerfile.cpu`
     - Took about 20-30 mins to build
   - Ran `kubectl create -f ./tensorflow-mnist.yaml`
   - Job never ran, nodes didn't finish building
   - Building `mpi-operator` created a `mpi-operator` namespace, so tried `kubectl create -n mpi-operator -f ./tensorflow-mnist.yaml`. Didn't work either
   - Noticed cpu, memory, demands were very large so I modified the `minikube config` to account
   - Even with increased resources, still didn't run

Next steps:
 - Try other examples?
 - Look at other troubleshooting strategies
 - Read through `issues` page on repo in more detail
 - Reach out to other people working with mpi & kubernetes?
 - ...
 - Figure out how to run our own mpi code
   - Looks confusing, but not too confusing.
