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
  config_path = "~/.kube/config"
}

provider "kubernetes-alpha" {
  config_path = "~/.kube/config"
  server_side_planning = true
}
