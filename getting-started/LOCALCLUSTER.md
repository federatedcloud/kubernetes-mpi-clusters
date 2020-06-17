Table of Contents
-----
 * [Running a Simple Cluster](LOCALCLUSTER.md#Running-a-Simple-Cluster)
 1. [Creating a Cluster](LOCALCLUSER.md#Creating-a-Cluster)
 2. [Deployments](LOCALCLUSTER.md#Deployments)
 3. [Pods and Nodes](LOCALCLUSTER.md#Pods-and-Nodes)
 4. [Services](LOCALCLUSTER.md#Services)
 5. [Scaling](LOCALCLUSTER.md#Scaling)
 6. [Updates](LOCALCLUSTER.md#Updates)

[back to README](README.md)

Running a Simple Cluster
=====
Kubernetes has a ton of utility for managing and deploying clusters. This guide will rely heavily on the interactive guide [here](https://kubernetes.io/docs/tutorials/kubernetes-basics/), with a few modifications and slightly less detail. While it is recommended to read through the information there, it isn't neccessary for getting started, and the interactive session isn't 100% compatible with the latest version of Minikube.

The guide is broken down into sections that each introduce a new concept about Kubernetes, building off each other. If you want to go away at any point, it may be good to run `minikube stop` and `minikube start` when you come back.

[top](LOCALCLUSTER.md#Table-of-Contents)

Creating a Cluster
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
(Image source: [Kubernetes Tutorial](https://kubernetes.io/docs/tutorials/kubernetes-basics/create-cluster/cluster-intro/))

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

[top](LOCALCLUSTER.md#Table-of-Contents)

Deployments
-----
To run applications with Kubernetes, you use a **Deployment**. This is a configuration that tells Kubernetes how to create and update instances of the application. If a Node running the application goes down, the Kubernetes Deployment Controller will notice and replace it with another instance on another Node.

We can now add detail to our broad view of the cluster by including deployments:
![Deployment Cluster](https://d33wubrfki0l68.cloudfront.net/152c845f25df8e69dd24dd7b0836a289747e258a/4a1d2/docs/tutorials/kubernetes-basics/public/images/module_02_first_app.svg)
(Image Source: [Kubernetes Tutorial](https://kubernetes.io/docs/tutorials/kubernetes-basics/deploy-app/deploy-intro/))

For this tutorial, the application to run will be writen in Node.js and packaged with Docker.

Unsurprisingly, kubectl is how we'll interact with the cluster to build the deployment. We use the `create` command with `deployment` to specify what we're building, and then provide an image to build from.
```
$ kubectl create deployment kubernetes-bootcamp --image=gcr.io/google-samples/kubernetes-bootcamp:v1
```
This command had three main effects
 * Searched for a Node where the application could run
 * Scheduled the application to run on that Node
 * Configured the cluster to reschdule the instance on a new Node when needed

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

In the next section, this proxy will be more useful, as we'll be interacting with containers we're running directly.

The corresponding part of the Kubernetes tutorial is found [here](https://kubernetes.io/docs/tutorials/kubernetes-basics/deploy-app/deploy-intro/)

[top](LOCALCLUSTER.md#Table-of-Contents)

Pods and Nodes
=====
Pods are the logical unit of Kubernetes. Each Pod is constructed to run a suite of tightly coupled containers. This is facilitated by the ability to provide shared resources for all containers within a Pod, such as
 * Shared storage (i.e. Volumes)
 * Networking with a unique cluster IP address
 * The 'big picture' of the Pod, including the container images and ports to use

In the last section, we made a Deployment. What happened behind the scenes was Kubernetes created a Pod running a container built from the image we provided.

Previously, we mentioned that Deployments can make process run on different Nodes if something crashes. Specifically, the entire Pod will be recreated identically on a separate node.

The following image shows levels of increasing complixity with Pods
![Pods](https://d33wubrfki0l68.cloudfront.net/fe03f68d8ede9815184852ca2a4fd30325e5d15a/98064/docs/tutorials/kubernetes-basics/public/images/module_03_pods.svg)

An individual Node can be running any number of Pods. The Master will assign Pods to Nodes such that the Load on each node is balanced.

When we add pods into our diagram, we get the following:
![Node with Pods](https://d33wubrfki0l68.cloudfront.net/5cb72d407cbe2755e581b6de757e0d81760d5b86/a9df9/docs/tutorials/kubernetes-basics/public/images/module_03_nodes.svg)
(Both Images from [Kubernetes Tutorial](https://kubernetes.io/docs/tutorials/kubernetes-basics/explore/explore-intro/))

Just like we could use `kubectl get pods` to see some basic information about our Pods, running `kubectl describe pods` will provide a detailed suite of information including
 * The IP address where we can access it
 * Any labels it has (more on that next!)
 * The image it's running
 * A log of events referring to that Pod

It's possible to access specific pieces of information about the cluster by running `kubectl get <resource> -o <template-style>` For this guide, we use `go-template`, but there may be better options.
To get the Pod name, run
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

Now that we have the Pod name, we can easily isolate the log by running
```
$ kubectl logs $POD_NAME
```
If our Pod had multiple containers, we would need to specify which container we're looking at. by writing `-c <container-name>` after the name of the pod. By default it uses the first container in the Pod.

It's possible to interact directly with the container inside our pod with `exec`. Try
```
$ kubectl exec $POD_NAME -- env
```
to see a list of environment variables in the container.
The same way of specifying which container we're interacting with applies here.

We can even run bash on this container! To do this, we need to allow the Pod to receive information from stdin with `-i` and make the formatting nice with `-t`, hence
```
$ kubectl exec -ti $POD_NAME -- bash
```

Now that we're inside the container, we can interact directly with our application. Try
```
cat server.js
```
to see the code we're running.
Also, we can look at the server by running
```
curl localhost:8080
```

That's it concerning Pods and containers for now, next we'll be looking at Services.

Relevant [link to Kubernetes official tutorial](https://kubernetes.io/docs/tutorials/kubernetes-basics/explore/explore-intro/)

[top](LOCALCLUSTER.md#Table-of-Contents)

Services
=====
Pods regularly 'die' and are rebuilt. When this happens, new Pods are created to restore the cluster. However, each Pod has a unique IP address, so we need a way to identify Pods by what they do instead of what they are.

For this, we introduce **Services**, which are an abstraction defining a logical set of pods and how to access them. It is usually defined with YAML, but can be written with JSON as well. For instance, interacting with a pod from outside the cluster requires a Service. Services can come in different types depending on what they are meant for.
 * _ClusterIP_ (default) - The Service is only reachable from within the cluster on a fixed IP
 * _NodePort_ - Exposes the Service on the same port of each selected Node. Accessible with `<NodeIP>:<NodePort>`
 * _LoadBalancer_ - Creates an external load balancer in the current cloud and assigns a fixed, external IP to the Service.

See [Using Source IP](https://kubernetes.io/docs/tutorials/services/source-ip/) and [Connecting Applications with Services](https://kubernetes.io/docs/concepts/services-networking/connect-applications-service).

In order to group the Pods a Service acts on, we use **Labels**, which can
 * Designate objects for development, test, and production
 * Embed version tags
 * Classify an object using tags

Now that we can group resources, Services can use a LabelSelector to define which Pods are under their jurisdiction.

Labels can be applied either when resources are created or while they are running.

Start by looking at the services currently running with
```
$ kubectl get services
```
The only service running should be kubernetes managing the entire cluster.

We can make a new Service with `expose` as follows
```
$ kubectl expose deployment/kubernetes-bootcamp --type="NodePort" --port 8080
```
Check that this is running and note the port it's using. Compare this to
```
$ kubectl describe services
```
Under Port(S) in the output of `get services`, you should see `8080:<Port>/TCP` and from `describe services` under `NodePort` you should see the same value as `<Port>/TCP`

We can add this port to our environment with the command
```
$ export NODE_PORT=$(kubectl get services/kubernetes-bootcamp -o go-template='{{(index .spec.ports 0).nodePort}}')
```
Check that `echo $NODE_PORT` gives the same number as before

Then running
```
$ curl $(minikube ip):$NODE_PORT
```
confirms that the Service is exposed.

When we added this Pod to the Service, it got the Label `app=kubernetes-bootcamp` which you can find by running `describe` in anything related to the Service. Confirm this by running
```
$ kubectl describe services
```

We can use this Label to filter the commands we run. Try it with
```
$ kubectl get services -l app=kubernetes-bootcamp
```
Note that now, only the one service with this filter shows up.

We can add our own tags with `label`, for instance
```
kubectl label pod $POD_NAME version=v1
```
As before, we can see this Label when we run
```
$ kubectl describe pods $POD_NAME
```
And again,
```
kubectl get pods -l version=v1
```
will give the only pod we have. If you try a different value for the `version` label in the filter, nothing will show up.

We can delete a service with `delete service` after providing a Label. Try
```
$ kubectl delete service -l app=kubernetes-bootcamp
```
And check that it is gone
```
$ kubectl get services
$ curl $(minikube ip):NODE_PORT
```

Note that the app is still running. Think about how you would check that this is the case given the tools we have.

One option is to run
```
$ kubectl exec -ti $POD_NAME curl localhost:8080
```
To shutdown the application, you would need to delete the Deployment.

Relevant [link to Kubernetes official tutorial](https://kubernetes.io/docs/tutorials/kubernetes-basics/expose/expose-intro/)

[top](LOCALCLUSTER.md#Table-of-Contents)

Scaling
=====
So far we've had only one Pod. One Pod may not be able to handle all the traffic the application needs. We can scale the number of Pods allocated for a Deployment up or down by creating or deleting replicas. Visually, this looks like moving between the two following images

![1 replica](https://d33wubrfki0l68.cloudfront.net/043eb67914e9474e30a303553d5a4c6c7301f378/0d8f6/docs/tutorials/kubernetes-basics/public/images/module_05_scaling1.svg)
![Many replicas](https://d33wubrfki0l68.cloudfront.net/30f75140a581110443397192d70a4cdb37df7bfc/b5f56/docs/tutorials/kubernetes-basics/public/images/module_05_scaling2.svg)
(Both images from [Kubernetes Tutorial](https://kubernetes.io/docs/tutorials/kubernetes-basics/scale/scale-intro/))

Deployments can be [autoscaled](https://kubernetes.io/docs/user-guide/horizontal-pod-autoscaling/) or even scaled to zero.

When we have multiple replicas of an application, Services balance the load between all available pods. 

We can look at how many replicas a Deployment has by running
```
$ kubectl get rs
```
Where `rs` stands for `ReplicaSet`. Intuitively, `DESIRED` shows how many replicas you want and `CURRENT` is how many are running.

We can scale the number of replicas with `kubectl scale` followed by the deployment and the number of instances.

To watch this happen, you can add the `-w` option to `get deployments` and run that right immediately after like so:
```
$ kubectl scale deployments/kubernetes-bootcamp --replicas=4 && \
    kubectl get deployments -w
```

This should show the replicas as they are produced. Use `Ctrl+C` to stop watching.

If we run `curl $(minikube ip):$NODE_PORT` repeatedly, we will get different Pods occassionally, demonstrating the load balancing.

By scaling nodes back, we can see them terminate. Try
```
$ kubectl scale deployments/kubernetes-bootcamp --replicas=2
$ kubectl get pods
```
Wait for ~10-20 seconds and check the pods again. They should go from Terminating to no longer showing up.

One advantage of scaling is the ability to apply updates without any downtime. We'll see this in the next section.

Relevant [link to Kubernetes official tutorial](https://kubernetes.io/docs/tutorials/kubernetes-basics/scale/scale-intro/)
[top](LOCALCLUSTER.md#Table-of-Contents)

Updates
-----
Kubernetes allows for **rolling updates** when you have multiple Pod instances. By default, Kubernetes only takes down and adds Pods one at a time, but this can be configured to numbers of percentages of Pods.

Furthermore, Kubernetes versions updates so they can be easily reverted if broken.

The process for updating looks like the following series of images
![1](https://d33wubrfki0l68.cloudfront.net/30f75140a581110443397192d70a4cdb37df7bfc/fa906/docs/tutorials/kubernetes-basics/public/images/module_06_rollingupdates1.svg)
![2](https://d33wubrfki0l68.cloudfront.net/678bcc3281bfcc588e87c73ffdc73c7a8380aca9/703a2/docs/tutorials/kubernetes-basics/public/images/module_06_rollingupdates2.svg)
![2](https://d33wubrfki0l68.cloudfront.net/9b57c000ea41aca21842da9e1d596cf22f1b9561/91786/docs/tutorials/kubernetes-basics/public/images/module_06_rollingupdates3.svg)
![3](https://d33wubrfki0l68.cloudfront.net/6d8bc1ebb4dc67051242bc828d3ae849dbeedb93/fbfa8/docs/tutorials/kubernetes-basics/public/images/module_06_rollingupdates4.svg)
(All images from [Kubernetes Tutorial](https://kubernetes.io/docs/tutorials/kubernetes-basics/update/update-intro/))

As you would expect, the Service load-balances appropriately when Pods are updating

Use `describe pods` and look at the image field for the version number. Then run
```
$ kubectl set image deployments/kubernetes-bootcamp kubernetes-bootcamp=jocatalin/kubernetes-bootcamp:v2
```
Watch the pods as they update

Now, if we check `curl $(minikube ip):$NODE_PORT` we should see the Pods it hits are running `v2`, which can be confirmed with
```
$ kubectl rollout status deployments/kubernetes-bootcamp
```
And by looking at the image field in `describe pods`.

If instead, we update to
```
$ kubectl set image deployments/kubernetes-bootcamp kubernetes-bootcamp=gcr.io/google-samples/kubernetes-bootcamp/v10
```
And watch the deployments... it gets stuck. `describe pods` shows us that in the updated Pods, the image didn't pull succesfully. This can be undone with
```
$ kubectl rollout undo deployments/kubernetes-bootcamp
```
Checking back on the pods using `get` and `describe` will show that the rollback was successful.

These are the basics of getting started with Kubernetes. In the following guides, we'll ddiscuss running Kubernetes on the cloud and integration with MPI

Relevant [link to Kubernetes official tutorial](https://kubernetes.io/docs/tutorials/kubernetes-basics/update/update-intro/)

[top](LOCALCLUSTER.md#Table-of-Contents)
