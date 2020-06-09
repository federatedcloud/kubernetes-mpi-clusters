Running a simple container
=====
Kubernetes has a ton of utility for managing and deploying clusters. This guide will rely heavily on the interactive guide [here](https://kubernetes.io/docs/tutorials/kubernetes-basics/), with a few modifications and slightly less detail. While it is recommended to read through the information there, it isn't neccessary for getting started, and the interactive session isn't 100% compatible with the latest version of Minikube.

The guide is broken down into sections that each introduce a new concept about Kubernetes, building off each other. If you want to go away at any point, it may be good to run `minikube stop` and `minikube start` when you come back.

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

You have now created a working cluster! Now we'll look at what Kubernetes lets us do with it.

relevant link [here](https://kubernetes.io/docs/tutorials/kubernetes-basics/create-cluster/cluster-intro/)

Deployments
-----
To run applications with Kubernetes, you use a **Deployment**. This is a configuration that tells Kubernetes how to create and update instances of the application. If a node running the application goes down, the Kubernetes Deployment Controller will notice and replace it with another instance on another node.

We can now add detail to our broad view of the cluster by including deployments:
![Deployment Cluster](https://d33wubrfki0l68.cloudfront.net/152c845f25df8e69dd24dd7b0836a289747e258a/4a1d2/docs/tutorials/kubernetes-basics/public/images/module_02_first_app.svg)

For this tutorial, the application to run will be writen in Node.js and packaged with Docker.

Unsurprisingly, kubectl is how we'll interact with the cluster to build the deployment. We use the `create` command with `deployment` to specify what we're building, and then provide an image to build from.
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

It's possible to access specific pieces of information about the cluster by running `kubectl get <resource> -o <template-style>` For this guide, we use `go-template`, but there may be better options.
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
Pods are the logical unit of Kubernetes. Each pod is constructed to run a suite of tightly coupled container. This is facilitated by the ability to provide shared resources for all containers within a pod, such as
 * Shared storage (i.e. Volumes)
 * Networking with a unique cluster IP address
 * The 'big picture' of the pod, including the container images and ports to use

In the last section, we made a Deployment. What happened behind the scenes was Kubernetes created a pod running a container built from the image we provided.

Previously, we mentioned that Deployments can make process run on different nodes if something crashes. Specifically, the entire pod will be recreated identically on a separate node.

The following image shows levels of increasing complixity with pods
![Pods](https://d33wubrfki0l68.cloudfront.net/fe03f68d8ede9815184852ca2a4fd30325e5d15a/98064/docs/tutorials/kubernetes-basics/public/images/module_03_pods.svg)

An individual node can be running any number of pods. The Master will assign pods to nodes such that the load on each node is balanced.

When we add pods into our diagram, we get the following:
![Node with Pods](https://d33wubrfki0l68.cloudfront.net/5cb72d407cbe2755e581b6de757e0d81760d5b86/a9df9/docs/tutorials/kubernetes-basics/public/images/module_03_nodes.svg)

Just like we could use `kubectl get pods` to see some basic information about our pods, running `kubectl describe pods` will provide a detailed suite of information including
 * The IP address where we can access it
 * Any labels it has (more on that next!)
 * The image it's running
 * A log of events referring to that pod

We can isolate the log by running
```
$ kubectl logs $POD_NAME
```
If our pod had multiple containers, we would need to specify which container we're looking at. by writing `-c <container-name>` after the name of the pod. By default it uses the first container in the pod.

It's possible to interact directly with the pod with the `exec` command. Try running
```
$ kubectl exec $POD_NAME -- env
```
to see a list of environment variables in the pod.
The same way of specifying which container we're interacting with applies here.

We can even run bash on this pod, as it's included in the container! To do this, we need to allow the pod to receive information from stdin with `-i` and make the formatting nice with `-t`, hence
```
$ kubectl exec -ti $POD_NAME -- bash
```

Now that we're inside the pod, we can interact directly with our application. Try
```
cat server.js
```
to see the code we're running.
While we're inside the container, we can look at the server by running
```
curl localhost:8080
```

That's it concerning pods and containers for now, next we'll be looking at services.

Relevant [link to Kubernetes official tutorial](https://kubernetes.io/docs/tutorials/kubernetes-basics/explore/explore-intro/)

Services
=====
