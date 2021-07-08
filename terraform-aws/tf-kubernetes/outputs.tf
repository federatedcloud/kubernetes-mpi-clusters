#locals {
#  config_map_aws_auth = <<CONFIGMAPAWSAUTH
#apiVersion: v1
#kind: ConfigMap
#metadata:
#  name: aws-auth
#  namespace: kube-system
#data:
#  mapRoles: |
#    - rolearn: ${aws_iam_role.node.arn}
#      username: system:node:{{EC2PrivateDNSName}}
#      groups:
#        - system:bootstrappers
#        - system:nodes
#CONFIGMAPAWSAUTH
#}
output "aws_credentials" {
  value = var.aws_credentials
  sensitive = "true"
}
output "region" {
  value = var.region
}
output "cluster_name" {
  value = var.cluster_name
}
output "profile" {
  value = var.profile
}
output "container_name" {
  value = var.container_name
}
