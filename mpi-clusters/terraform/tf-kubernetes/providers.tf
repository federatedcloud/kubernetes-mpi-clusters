terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    google-beta = {
      source = "hashicorp/google-beta"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    kubernetes-alpha = {
      source = "hashicorp.com/kubernetes/kubernetes-alpha"
      versions = ["0.1.0"]
    }
  }
  required_version = ">= 0.13"
}

provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = file(var.google_credentials)
}

provider "google-beta" {
  project     = var.project_id
  region      = var.region
  credentials = file(var.google_credentials)
}

provider "kubernetes" {
  load_config_file = true
  config_path = "~/.kube/config"
}

provider "kubernetes-alpha" {
  server_side_planning = true
  config_path = "~/.kube/config"
}
