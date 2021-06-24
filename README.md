# kubernetes-mpi-clusters
Scripts and documentation to build Kubernetes clusters with MPI to run scientific computing and HPC software in the public cloud

To learn how to use kubernetes, explore the contents of the [getting-started](getting-started) directory. 

The resources in the [terraform-gcp](terraform-gcp) and [terraform-aws](terraform-aws) directories automate the creation of a Kubernetes cluster on the respective platform that is capable of using MPI.

While the use of Terraform to create clusters in the public cloud is well-known, there is currently no easy way to utilize MPI in Google Cloud or AWS. However, through integration with Kubernetes, we can use mpi-operator to open those communication channels. The coniguration and scripts in this repository package the entire process, from cluster creation to running your workload, into one automated tool.

MPI-Operator
============
Documentation provided at the [mpi-operator repo](https://github.com/kubeflow/mpi-operator)
 - There is now a working and fully documented set-up with terraform and mpi-operator on Google Cloud in [terraform-gcp/](terraform-gcp)
 - It can also be deployed using .yaml files, provided that your cluster is running Kubernetes 1.17+

Public Cloud
============
Currently there are two supported cloud service providers, Google Cloud Platform (GCP) and Amazon Web Services (AWS). We may add support for Azure in the future as well. These services aren't free, but there are ways to get free credits, especially if you are doing research.

GCP Automatically gives new accounts $300 worth of credits, whereas AWS has various options to apply for credits. To get started with GCP,

1. Create an account with GCP
2. Create a Cloud project from the [Cloud Console project selector page](https://console.cloud.google.com/home/dashboard?authuser=1)
3. Make sure billing is enabled (it should be automatically) [here](https://cloud.google.com/billing/docs/how-to/modify-project)

There are more configuration options available, but this is enough to get started.

GCP First Steps
===============
The simplest tutorial for getting started is pretty much a [containerized online hello world](https://cloud.google.com/kubernetes-engine/docs/tutorials/hello-app?authuser=1). If you followed the previous guides, everything related to Kubernetes should be familiar, so this will only expand upon the new features specific to GCP.

There are 3 ways to guide your workflow with GCP
 - Local command line. You will need to follow the remaining installation procedure
    - The page [here](https://cloud.google.com/sdk/install) has a full list of installation methods.
    - For Ubuntu/Debian, `gcloud` is available through `apt-get` after gettting the Google Cloud public key. There are specific instructions [here](https://cloud.google.com/sdk/docs/downloads-apt-get)
    - Run `gcloud init`. This will prompt you for a default project. Use the one you created earlier. 
 - Cloud Shell. GCP provides an online shell that has all the tools you need to get started.
 - Cloud Console. There is an online interface where all the same actions on the command line can be done by clicking on various menus and buttons.

The Console makes it easy to see all the available options and is often a good way to check that everything is configured correctly, or to perform simple operations. The Shell is useful due to its ease of access and minimal setup required. For scripted interactions with GCP, the CLI is the best option.

Google Kubernetes Engine (GKE) provides many tools to make your life easier. Some of the more important ones are given here. 
 - The Clusters tab shows you the clusters available. Individual clusters are located either in a specific Zone or a Region that encompasses multiples zones. For a given cluster, you have control over automation, networking, security, metadata, and extra features. A cluster can have multiple node pools, which are related sets of nodes. 
   Every node in a node pool is set up identically to the other nodes in that pool. You can specify the zone this pool is in, the number of nodes, what type of machine (how many cpu, how much memory) they run on, whether or not they have a GPU, if so, what kind and how many, how much disk space, as well as security and metadata. Some of this can be edited after creation of a cluster, but you may need to make new node pools if, for instance, you had to run a GPU application and didn't have any nodes with GPUs.
 - The Workloads page is geared towards 'Deploying containerized applications'. You can either provide a container image or, with the Cloud Source Repositories API, have it build one from a given repository. You aren't limited to just one container, but can create multiple at once. Then, you add options to your kubernetes deployment, which GKE turns into a configuration YAML file (which you can manually inspect) and deploys. 
 - Services are a way to communicate with your pods, which requires opening channels for communication. The Services and Ingress tab allows you to manage that aspect of Kubernetes.
 - The Storage tab simply lets you view the extra storage you've mounted into the system and what can access it
 - Finally, the Object Browser list every resource, sorted by type, so you can see everything in your cluster in one place.

Mpi-Operator: Horovod example
-----------------------------
Once you've finished the `hello-app` tutorial, consider the following example from the `mpi-operator` Github repository.

Note: This build requires building a container that may take up to 30 minutes

1. In the Shell, clone the repository
   ```
   $ git clone https://github.com/kubeflow/mpi-operator
   $ cd mpi-operator
   ```
2. Deploy the operator
   ```
   $ kubectl create -f deploy/v1alpha2/mpi-operator.yaml
   ```
   Note that this step requires the ability to create a `ClusterRoleBinding` resource on GKE. Make sure you have `KubernetesAdmin` privileges.
3. Using the Cloud Console, make a cluster or node pool that has nodes with enough compute resources.
    - Under 'Cluster Basics' name the node pool (e.g., `horovod-pool`) and enable autoscaling (optional, recommended).
    - On the sidebar, you should see name you just wrote. Select the 'Nodes' submenu
    - Change the machine type. The `n1-standard-4` is a reasonable option.
    - Click `Create` at the bottom of the page.
4. `$ cd examples/horovod`
5. Rename the Dockerfile with
   ```
   $ mv Dockerfile.cpu Dockerfile
   ```
6. Run
   ```
   $ gcloud builds submit --tag gcr.io/<project-id>/horovod-image --timeout=1h
   ```
   Where `<project-id>` is your Cloud project ID. This may take > 30 minutes.
7. Edit the file `tensorflow-mnist.yaml`. In *both* places where it gives the image name, change it to `gcr.io/<project-id>/horovod-image:latest`
8. Run `kubectl create -f ./tensorflow-mnist.yaml`
9. Monitor the progress by looking at the following outputs
    - `kubectl get pods` Will tell you the if the pods have initialized properly. It may take a few minutes, but they should all be `Running` in the end.
    - `kubectl describe pods` Will tell you what went wrong, if anything, in the `logs` section.
    - `kubectl get -o yaml mpijobs tensorflow-mnist` Will tell you the overall status of the training.
    - 
    ```
    $ PODNAME=$(kubectl get pods -l mpi_job_name=tensorflow-mnist,mpi_role_type=launcher -o name)
    $ kubectl logs -f ${PODNAME}
    ```
    Will tell you how the setup and training are progressing.
10. The entire training process takes nearly an hour to complete and the results aren't important to running mpi jobs. You can `kubectl delete mpijob tensorflow-mnist` once you've verified it is training.
11. Delete your cluster or node pool to clean everything up, if desired.
