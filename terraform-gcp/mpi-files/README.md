#Files to add into container

This directory is the location to store small files that you may want to add to the containers running in Google Cloud. For files smaller than 1 MiB, you can do this easily using a [ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#add-configmap-data-to-a-volume) as we demonstrate in [mpi-operator.tf](tf-kubernetes/mpi-operator.tf).
For larger files, you can store them in one of many types of Kubernetes volumes, such as an nfs share, consider adding them to your image, or write a script to run on the container to edit an existing file to have the desired properties.
