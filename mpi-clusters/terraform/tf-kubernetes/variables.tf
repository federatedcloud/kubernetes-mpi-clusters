variable "project_id" {
  description = "project id"
}

variable "owner" {
  default     = ""
  description = "identifier of person running tf-kubernetes"
}

variable "region" {
  description = "region"
}

variable "zone" {
  description = "zone"
}

variable "zonal_cluster" {
  default = false
  type    = bool
  description = "Sets either regional or zonal cluster"
}

variable "gke_nodes_per_zone" {
  default     = 1
  description = "number of gke nodes per instance group"
}

variable "google_credentials" {
  description = "path to google credentials file"
}

variable "machine_type" {
  default     = "n1-standard-1"
  description = "machine type"
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
