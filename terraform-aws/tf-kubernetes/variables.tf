variable "region" {
  default     = "us-east-1"
  description = "AWS region to run the cluster in"
}
variable "profile" {
  description = "name of configured AWS profile"
}
variable "aws_credentials" {
  description = "path to aws credentials csv"
}
variable "cluster_name" {
  default     = "tf-kubernetes"
  description = "name of EKS cluster"
}
variable "instance_type" {
  default     = "t3.medium"
  description = "type of AWS VM"
}
variable "input_file_name" {
  default     = "../mpi-files/WRF-script.sh"
  description = "local location of script added to worker nodes"
}
variable "remote_file_name" {
  default     = "WRF-script.sh"
  description = "where on worker nodes script is added"
}
variable "container_name" {
  default     = "wrf"
  description = "name of mpijob-related resources"
}
variable "runscript" {
  default     = "echo Hello World"
  description = "command for launcher node to run"
}
variable "image_id" {
#  default     = "cornellcac/nix-mpi-benchmarks:a4f3cd63f6994703bbaa0636f4ddbcc87e83ea05"
  default     = "cornellcac/wrf:3.8.1-fitch@sha256:ee2f88b1db2f72df03fb7627e5f25040caa02100600d7c0105d3e6ad6666ff3f"
  description = "docker image for launcher and worker containers"
}
variable "num_workers" {
  default     = 2
  description = "number of compute nodes and worker pods"
}
variable "slots_per_worker" {
  default     = 2
  description = "number of mpi slots per worker pod"
}
