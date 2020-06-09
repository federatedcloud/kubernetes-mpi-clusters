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
