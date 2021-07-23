terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.69"
    }
  }

  required_version = ">= 0.14.9"
}

locals {
  sp_cred = jsondecode(file("${path.root}/sp-cred.json"))
}

provider "azurerm" {
  features {}

  subscription_id = local.sp_cred.subscriptionId
  client_id       = local.sp_cred.appId
  client_secret   = local.sp_cred.password
  tenant_id       = local.sp_cred.tenant
}

resource "azurerm_resource_group" "main" {
  name     = "tf-kubernetes"
  location = "East US"
}
