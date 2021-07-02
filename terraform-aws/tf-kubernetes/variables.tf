variable "profile" {
  description = "name of aws profile"
}

variable "region" {
  default     = "us-east-2"
  description = "cluster region"
}

variable "cluster_name" {
  default     = "tf-kubernetes"
  description = "EKS name of cluster"
}

variable "num_nodes" {
  default     = 1
  description = "number of EC2 nodes"
}

variable "aws_credentials" {
  description = "path to google credentials file inside container"
}

variable "machine_type" {
  default     = "n1-standard-1"
  description = "virtual machine type"
}

variable "num_workers" {
  default     = 2
  description = "number of worker pods"
}

variable "slots_per_worker" {
  default     = 2
  description = "number of mpi slots per worker"
}

variable "image_id" {
  default     = "cornellcac/nix-mpi-benchmarks:a4f3cd63f6994703bbaa0636f4ddbcc87e83ea05"
  description = "docker image to run"
}

variable "container_name" {
  default     = "hpl-benchmarks"
  description = "name of container running in pods"
}

variable "runscript" {
  default     = "mpirun -np 4 --bind-to core --map-by slot xhpl"
  description = "mpirun command"
}

variable "path_to_file" {
  default     = "../mpi-files/HPL.dat"
  description = "Location of file that will be mounted via configmap"
}
