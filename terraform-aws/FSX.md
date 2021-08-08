FSX Lustre
----------

In our attempts to emulate a Stampede2 environment on AWS, one option we explored was an [AWS FSx Lustre Filesystem](https://aws.amazon.com/fsx/lustre/), which is what they use in their `$work`, `$work2`, and `$scratch` directories mounted to every node.

A Lustre filesystem is a parallel filesystem with three parts, one or more _metadata servers_ (MDS), one or more _object storage servers_ (OSS), and a collection of _clients_. The MDS stores access information, like filenames, directories, access permissions and file layout, while the OSS stores the actual object data. This system allows for large amounts of data (PB-scale) to be readily available throughout the cluster with low latency.

There are various guides for how to use FSx with Kubernetes. For example:
- [This AWS blog post](https://aws.amazon.com/blogs/opensource/using-fsx-lustre-csi-driver-amazon-eks/)
- [This userguide](https://docs.aws.amazon.com/eks/latest/userguide/fsx-csi.html)
- [This excerpt from a virtual workshop](https://www.eksworkshop.com/beginner/190_fsx_lustre/launching-fsx/)
- [This example from the github](https://github.com/kubernetes-sigs/aws-fsx-csi-driver/tree/master/examples/kubernetes/dynamic_provisioning)

And likely many more. They are centered around the [AWS FSx CSI Driver](https://github.com/kubernetes-sigs/aws-fsx-csi-driver/), which dynamically provisions the filesystem when there are one or more pods requesting access to it. 

The current code attempts to follow the virtual workshop linked above, but is currently unsuccessful. There are a few possible scenarios:
- The AWS FSx CSI Driver repository (linked above) says dynamic provisioning isn't workng right now. There was a recent update to their helm chart, but that might not be a complete fix.
- Instead of dynamically provisioning the FSx Lustre filesystem, we might be able to create one with terraform and have Kubernetes find and attach it.
- A different guide might have better resources, specifically for using it with Terraform.
