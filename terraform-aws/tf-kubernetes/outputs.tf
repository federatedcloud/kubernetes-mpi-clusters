output "aws_credentials" {
  value       = var.aws_credentials
  description = "Path to csv credentials file"
  sensitive   = true
}

output "region" {
  value       = var.region
  description = "Cluster region"
}

output "cluster_name" {
  value       = var.cluster_name
  description = "Name of cluster"
}

output "container_name" {
  value       = var.container_name
  description = "Name of remote container"
}
