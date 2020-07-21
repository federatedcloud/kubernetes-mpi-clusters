variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "region"
}

variable "gke_username" {
  default     = ""
  description = "gke username"
}

variable "gke_password" {
  default     = ""
  description = "gke password"
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
