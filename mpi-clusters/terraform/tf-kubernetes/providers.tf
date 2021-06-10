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
      version = "2.3.1"
    }
    kubernetes-alpha = {
      source = "hashicorp/kubernetes-alpha"
      version = "0.4.1"
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
  config_path = "~/.kube/config"
}

provider "kubernetes-alpha" {
  config_path = "~/.kube/config"
}
