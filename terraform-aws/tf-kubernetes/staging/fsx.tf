resource "kubernetes_storage_class" "fsx" {
  metadata {
    name = "fsx-sc"
  }
  storage_provisioner = "fsx.csi.aws.com"
  parameters = {
    subnetId = aws_subnet.main.0.id
    securityGroupIds = aws_security_group.cluster.id
    s3ImportPath = "wrf-fsx-lustre"
    s3ExportPath = "wrf-fsx-lustre/export"
    deploymentType = "SCRATCH_2"
  }
  mount_options = ["flock"]
}

resource "kubernetes_persistent_volume_claim" "fsx" {
  metadata {
    name = "fsx-claim"
  }
  spec {
    access_modes = ["ReadWriteMany"]
    storage_class_name = "fsx-sc"
    resources {
      requests = {
        storage = "1200Gi"
      }
    }
  }
}
