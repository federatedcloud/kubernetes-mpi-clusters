variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "region"
}

variable "gke_num_nodes" {
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

variable "container_name" {
  default     = "hpl-benchmarks"
  description = "name of container running in pods"
}
