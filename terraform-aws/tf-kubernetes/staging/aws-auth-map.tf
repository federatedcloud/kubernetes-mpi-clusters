resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name = "aws-auth-test"
    namespace = "kube-system"
  }
  data = {
    mapRoles = [
      {
        rolearn = aws_iam_role.node.arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups = [
          "system:bootstrappers",
          "system:nodes"
        ]
      }
    ]
  }
}
