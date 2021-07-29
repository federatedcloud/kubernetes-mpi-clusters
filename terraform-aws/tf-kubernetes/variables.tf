variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region to run the cluster in"
}
variable "profile" {
  type        = string
  description = "name of configured AWS profile"
}
variable "aws_credentials" {
  type        = string
  description = "path to aws credentials csv"
}
variable "cluster_name" {
  type        = string
  default     = "tf-kubernetes"
  description = "name of EKS cluster"
}
variable "worker_instance_type" {
  type        = string
  default     = "t3.medium"
  description = "type of AWS VM for worker node"
}
variable "launcher_instance_type" {
  type        = string
  default     = "t3.medium"
  description = "type of AWS VM for launcher node"
}
variable "container_name" {
  type        = string
  default     = "wrf"
  description = "name of mpijob-related resources"
}
variable "runscript" {
  type        = string
  default     = "echo Hello World"
  description = "command for launcher node to run"
}
variable "image_id" {
  type        = string
  default     = "cornellcac/nix-mpi-benchmarks:a4f3cd63f6994703bbaa0636f4ddbcc87e83ea05"
  description = "docker image for launcher and worker containers"
}
variable "num_workers" {
  type        = number
  default     = 2
  description = "number of compute nodes and worker pods"
}
variable "slots_per_worker" {
  type        = number
  default     = 2
  description = "number of mpi slots per worker pod"
}
variable "nfs_server_ip" {
  type        = string
  description = "ClusterIP of nfs server"
}
