terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.32.0"
    }
    google-beta = {
      source = "hashicorp/google-beta"
      version = "3.32.0"

    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "1.12.0"
    }
    kubernetes-alpha = {
      source = "hashicorp/kubernetes-alpha"
      version = "0.2.0"
    }
  }
  required_version = ">= 0.14"
}

provider "google" {
  project     = var.project_id
  zone        = var.zone
  credentials = file(var.google_credentials)
}

provider "google-beta" {
  project     = var.project_id
  zone        = var.zone
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
