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
  location       = var.region
  version_prefix = "1.17."
}

resource "google_container_cluster" "primary" {
  provider = google-beta

  name     = "kubernetes-tf-cluster"
  location = var.region

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

  name     = "${google_container_cluster.primary.name}-node-pool"
  location = var.region
  cluster  = google_container_cluster.primary.name

  initial_node_count = 1
  autoscaling {
    min_node_count = 0
    max_node_count = 6
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.project_id
    }

    # preemptible  = true
    machine_type = var.machine_type
    tags         = ["gke-node", "${google_container_cluster.primary.name}"]
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
output "region" {
  value       = var.region
  description = "region"
}
