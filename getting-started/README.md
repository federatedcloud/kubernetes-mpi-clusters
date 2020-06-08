How to get started
=====
You'll first need to install Kubernetes, Minikube, and Docker. 

Kubernetes
-----
The first tool is kubectl. This is how you're going to interact with a Kubernetes cluster, at least at the beginning.

The easiest way is to use snap or homebrew. The corresponding commands are
```
$ snap install kubectl --classic'
```
and
```
$ brew install kubectl
```
Alternatively, you can install a binary and make it executable using the following:
```
$ curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
$ chmod +x ./kubectl
$ sudo mv ./kubectl /usr/local/bin/kubectl
```

Regardless of which way you installed kubectl, test that it is installed properly by running
```
$ kubectl version --client
```

Note that this step of the guide came from [the official Kubernetes installation guide](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-linux)

Docker
-----
Docker is one of the default tools for running Minikube, so it's worth installing.
It is used for containerization and version control of applications. The installations can vary depending on your OS or distribution. For example, the following instructions work for Ubuntu.

First navigate [here](https://docs.docker.com/engine/install/) to find the appropriate list of releases. For Ubuntu, you'll want to follow the link [here](https://docs.docker.com/engine/install/ubuntu/)

To ensure a clean install, you can remove previous versions of docker tools with
```
$ sudo apt-get remove docker docker-engine docker.io containerd runc
```
(If you have none installed, apt will tell you so and exit safely)

The two best options are to set up the docker repo or to manually install a .deb file. For a repo, run
```
$ sudo apt-get update
$ sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent sofware-properties-common
```
You'll need the docker GPG key
```
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```
Verify the key with a fingerprint. Running
```
$ sudo apt-key fingerprint 0EBFCD88
```
Should have the string
```
9DC8 5822 9FC7 DD38 E2D8 8D81 803C 0EBF CD88
```
in the second line of the output.

Next, you'll need to add the stable repository, which can vary by system so again refer to the previous link, but it is a command similar to
```
$ sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
```

Next, run
```
$ sudo apt-get update
$ sudo apt-get install docker-ce docker-ce-cli containerd.io
```

Alternatively, packages can be found [here (for ubuntu)](https://download.docker.com/linux/ubuntu/dists/) and can then be installed by
```
$ sudo dpkg -i /path/to/package.deb
```

Finally, run
```
$ sudo docker run hello-world
```
To make sure docker is installed correctly. Consider looking into user groups so you don't have to write `sudo` before every docker command.

Minikube
-----
Minikube is a way of running a Kubernetes cluster locally without having to pay for public computing time or messing around with setting up VMs and all that. It's a great way to get used to the basic functionality of Kubernetes.
There are packages you can install [here](https://github.com/kubernetes/minikube/releases)

Alternatively, you can run
```
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
  && chmod +x minikube
sudo mkdir -p /usr/local/bin/
sudo install minikube /usr/local/bin/
```
The last two lines ensure `minikube` is executable on your path.

Or, you can run
```
brew install minikube
```
Note: While minikube is available through `snap`, the most recent version is from 9/26/16 and hasn't been confirmed to work with this guide.

After this is installed, check that it has been done properly with
```
minikube version
```

This step comes from [the minikube installation guide](https://kubernetes.io/docs/tasks/tools/install-minikube/) which has useful information about security and hypervisors.

Running a simple container
=====
Kubernetes has a ton of utility for managing and deploying clusters. This guide will rely heavily on the interactive guide [here](https://kubernetes.io/docs/tutorials/kubernetes-basics/), with a few modifications and slightly less detail. It is highly recommended to read through what is written there as there are some great images and links to further reading. Also, executing commands on the interactive shell may be clunky/not engaging.

The guide is broken down into sections that each introduce a new concept about Kubernetes, building off each other. If you want to go away at any point, it may be good to run `minikube stop` and `minikube start`.

Creating a cluster
-----
Kubernetes abstracts the idea of containerized applications running on a network of machines such that the user doesn't have to manually set up every single interactions between machines, but rather "**automate the distribution and scheduling of application containers across a cluster in a more efficient way**"

The simplest division of labor in a Kubernetes cluster is the two roles that kubernetes resources have
 * A **Master Node**
   * Schedules applications
   * Maintains applications' desired state
   * Scales applications
   * Rolls out updates
 * (possibly multiple) **Node**(s)
   * Run the application, workers that take on tasks
   * Each one has a Kubelet, which manages that node and communicates with the master
   * Perform container operations

The broadest overview of a Kubernetes cluster is something like this:
![Kubernetes cluster](https://d33wubrfki0l68.cloudfront.net/99d9808dcbf2880a996ed50d308a186b5900cec9/40b94/docs/tutorials/kubernetes-basics/public/images/module_01_cluster.svg)

In this tutorial, your machine will act as a master node, and Minikube will create a VM on your machine that contains a cluster with one node.

First, activate minikube with
```
$ minikube start
```
This may take a minute.

When it finishes initializing, make sure it's running with
```
$ kubectl cluster-info
```
To view nodes in the cluster, use
```
$ kubectl get nodes
```
`get` is a command that will print a list of all the instances of whatever resource is provided after it. In this case, we get a list of every node in the cluster.

As far as making a cluster with minikube... that's it! Now we'll look at what functionality Kubernetes provides

relevant link [here](https://kubernetes.io/docs/tutorials/kubernetes-basics/create-cluster/cluster-intro/)

Deployments
-----
To run applications with Kubernetes, you use a **Deployment**. This is a configuration that tells Kubernetes how to create and update instances of the application. If a node running the application goes down, the Kubernetes Deployment Controller will notice and replace it with another instance on another node.

We can now add detail to our broad view of the cluster by including deployments:
![Deployment Cluster](https://d33wubrfki0l68.cloudfront.net/152c845f25df8e69dd24dd7b0836a289747e258a/4a1d2/docs/tutorials/kubernetes-basics/public/images/module_02_first_app.svg)

For this tutorial, the application to run will be writen in Node.js and packaged with Docker.

Unsurprisingly, kubectl is how we'll interact with the cluster to build the deployment. We use the `create` command and specify `deployment` to specify what we're building, and then provide an image to build from.
```
$ kubectl create deployment kubernetes-bootcamp --image=gcr.io/google-samples/kubernetes-bootcamp:v1
```
This command had three main effects
 * Searched for a node where the application could run
 * Scheduled the application to run on that node
 * Configured the cluster to reschdule the instance on a new node when needed

Just like how we could list our nodes with `kubectl get nodes`, we can list deployments with
```
$ kubectl get deployments
```
By default, Kubernetes clusters can only communicate internally. For you to interact with them, you'll have to open a proxy. Open a second terminal window and run
```
$ kubectl proxy
```
This won't produce one line of output and then continuously run, but can be stopped with `Ctrl+C`. For now, return to the previous terminal.

To see that you can interact, try running
```
$ curl http://localhost:8001/version
```

It's possible to access specific pieces of information about the cluster by running `kubectl get <resource> -o <templace-style>` For this guide, we use `go-template`, but there may be better options.
To get the pod name, run
```
export POD_NAME=$(kubectl get pods -o go-template --template '{{range.items}}{{.metadata.name}}{{"\n"}}{{end}}')
```
Confirm the output is correct by comparing
```
echo $POD_NAME
```
to the corresponding entry in
```
kubectl get pods
```
The corresponding part of the Kubernetes tutorial is found [here](https://kubernetes.io/docs/tutorials/kubernetes-basics/deploy-app/deploy-intro/)

Pods and Nodes
=====

