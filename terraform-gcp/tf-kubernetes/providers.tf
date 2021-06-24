terraform {
  ## Sets minimum provider versions
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.72.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 3.72.0"

    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.3.1"
    }
    kubernetes-alpha = {
      source  = "hashicorp/kubernetes-alpha"
      ## Some issues updating to 0.5.0
      version = "0.4.1"
    }
  }
  # Minimum terraform version
  required_version = ">= 0.14"
}

provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
  credentials = file(var.google_credentials)
}

provider "google-beta" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
  credentials = file(var.google_credentials)
}

## No credentials given in provider block, authenticate via gcloud
provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "kubernetes-alpha" {
  config_path = "~/.kube/config"
}
