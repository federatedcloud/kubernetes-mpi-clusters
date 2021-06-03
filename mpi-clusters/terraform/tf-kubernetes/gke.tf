resource "google_compute_network" "vpc" {
  name                    = "kubernetes-tf-network"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnet" {
  name          = "kubernetes-tf-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
}

data "google_container_engine_versions" "east4" {
  provider       = google-beta
  project        = var.project_id
  location       = var.zonal_cluster ? var.zone : var.region
  version_prefix = "1.17."
}

resource "google_container_cluster" "primary" {
  provider = google-beta

  name     = "kubernetes-tf-cluster"
  location = var.zonal_cluster ? var.zone : var.region

  remove_default_node_pool = true
  initial_node_count       = 1

  node_version = data.google_container_engine_versions.east4.release_channel_default_version["RAPID"]
  min_master_version = data.google_container_engine_versions.east4.release_channel_default_version["RAPID"]
  release_channel {
    channel = "RAPID"
  }

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "primary_nodes" {
  provider = google-beta
  # Newer versions might change this syntax
  name     = "${google_container_cluster.primary.name}-node-pool"
  location = var.zonal_cluster ? var.zone : var.region
  cluster  = google_container_cluster.primary.name

  node_count = var.gke_nodes_per_zone

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.project_id
      resource = "tf-kubernetes-cluster"
      owner    = var.owner
    }

    # preemptible  = true
    machine_type = var.machine_type
    # Newer versions might change this syntax
    tags         = ["gke-node", google_container_cluster.primary.name]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

output "cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
}
output "version" {
  value       = google_container_cluster.primary.master_version
  description = "master version"
}
output "project_id" {
  value       = var.project_id
  description = "GCP project id"
}
output "zone" {
  value       = var.zone
  description = "zone"
}
output "region" {
  value       = var.region
  description = "region"
}
output "google_credentials_file" {
  value       = var.google_credentials
  description = "path to google credentials file"
}
output "container_name" {
  value       = var.container_name
  description = "name of remote container"
}
output "mpi_file_dest" {
  value       = var.mpi_file_dest
  description = "where to inject additional mpi files into nodes"
}
