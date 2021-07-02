terraform {
  ## Sets minimum provider versions
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.47.0"
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

provider "aws" {
  region  = var.region
  profile = var.profile
}

## No credentials given in provider block, authenticate via aws CLI
provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "kubernetes-alpha" {
  config_path = "~/.kube/config"
}
