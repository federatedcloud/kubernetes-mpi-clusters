## Set up network to enable cluster communication
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

## Find versions of kubernetes to run the cluster on
data "google_container_engine_versions" "versions" {
  provider       = google-beta
  project        = var.project_id
  location       = var.zonal_cluster ? var.zone : var.region
  version_prefix = "1.20."
}

## Create GKE Cluster
resource "google_container_cluster" "primary" {
  name     = "kubernetes-tf-cluster"
  location = var.zonal_cluster ? var.zone : var.region
  ## Removing default node pool gives more control over nodes
  remove_default_node_pool = true
  #initial_node_count       = 1
  ## Ensure stable kubernetes version
  #min_master_version = data.google_container_engine_versions.versions.release_channel_default_version["RAPID"]
  min_master_version = "1.20.7-gke.1800"
  enable_kubernetes_alpha = true
  release_channel {
    channel = "UNSPECIFIED"
  }
  node_pool {
    name = "default-pool"
    initial_node_count = 1
    management {
      auto_repair = false
      auto_upgrade = false
    }
  }
  lifecycle {
    ignore_changes = [
      node_pool
    ]
  }

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
}

## Add launcher node
resource "google_container_node_pool" "launcher_node" {
  name     = "${google_container_cluster.primary.name}-launcher-node-pool"
  location = var.zonal_cluster ? var.zone : var.region
  cluster  = google_container_cluster.primary.name
  #version  = data.google_container_engine_versions.versions.release_channel_default_version["RAPID"]
  version  = "1.20.7-gke.1800"

  management {
    auto_repair  = false
    auto_upgrade = false
  }

  node_count     = 1
  node_locations = [ var.zone ]
  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
    ## Equivalent to Kubernetes node labels
    labels = {
      env      = var.project_id
      resource = "tf-kubernetes-cluster"
      owner    = var.owner
      role     = "launcher"
    }

    # preemptible  = true
    machine_type = var.launcher_machine_type
    tags         = ["gke-node", google_container_cluster.primary.name]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
## Add worker nodes
resource "google_container_node_pool" "worker_nodes" {
  name     = "${google_container_cluster.primary.name}-worker-node-pool"
  location = var.zonal_cluster ? var.zone : var.region
  cluster  = google_container_cluster.primary.name
  #version    = data.google_container_engine_versions.versions.release_channel_default_version["RAPID"]
  version  = "1.20.7-gke.1800"
 
  management {
    auto_repair  = false
    auto_upgrade = false
  }

  node_count = var.gke_nodes_per_zone
  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
    ## Equivalent to Kubernetes node labels
    labels = {
      env      = var.project_id
      resource = "tf-kubernetes-cluster"
      owner    = var.owner
      role     = "worker"
    }

    # preemptible  = true
    machine_type = var.worker_machine_type
    tags         = ["gke-node", google_container_cluster.primary.name]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

## Outputs printed that are used in various scripts
output "cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
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
  sensitive   = true
}
output "container_name" {
  value       = var.container_name
  description = "name of remote container"
}
