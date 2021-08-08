## OIDC provider
locals {
  cluster_url = aws_eks_cluster.main.identity.0.oidc.0.issuer
  cluster_url_no_https = replace(local.cluster_url, "https://", "")
}
data "tls_certificate" "cluster" {
  url = local.cluster_url
}

resource "aws_iam_openid_connect_provider" "fsx" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates.0.sha1_fingerprint]
  url             = local.cluster_url
}
  
## Create IAM Role for FSx
## Gets information such as account id
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "fsx_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
  
    condition {
      test     = "StringEquals"
      variable = "${local.cluster_url_no_https}:sub"
      values   = ["system:serviceaccount:kube-system:fsx-csi-controller-sa"]
    }
    principals {
      type        = "Federated"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.cluster_url_no_https}"
      ]
    }
  }
}

resource "aws_iam_role" "fsx" {
  name               = "fsx-csi-controller-sa"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.fsx_role.json
}

## Give nodes permissions to use FSx
data "aws_iam_policy_document" "fsx_csi_driver" {
  statement {
    actions = [
      "iam:CreateServiceLinkedRole",
      "iam:AttachRolePolicy",
      "iam:PutRolePolicy"
    ]
    effect    = "Allow"
    resources = ["arn:aws:iam::*:role/aws-service-role/s3.data-source.lustre.fsx.amazonaws.com/*"]
  }
  statement {
    actions   = ["iam:CreateServiceLinkedRole"]
    effect    = "Allow"
    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "iam:AWSServiceName"
      values   = ["fsx.amazonaws.com"]
    }
  }
  statement {
    actions = [
      "s3:ListBucket",
      "fsx:CreateFileSystem",
      "fsx:DeleteFileSystem",
      "fsx:DescribeFileSystems"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_policy" "fsx_csi_driver" {
  description = "Permissions required to use AWS FSx Lustre"
  name        = "fsx-csi-driver"
  path        = "/"
  policy      = data.aws_iam_policy_document.fsx_csi_driver.json
}

resource "aws_iam_role_policy_attachment" "fsx_csi_driver" {
  policy_arn = aws_iam_policy.fsx_csi_driver.arn
  role       = aws_iam_role.fsx.name
}

## Add kubernetes RBAC
## From https://github.com/kubernetes-sigs/aws-fsx-csi-driver/blob/master/deploy/kubernetes/base/rbac.yaml
resource "kubernetes_service_account" "fsx_csi_controller" {
  depends_on = [aws_iam_role_policy_attachment.fsx_csi_driver]
  metadata {
    name      = "fsx-csi-controller-sa"
    namespace = "kube-system"
    ## Connects AWS Role to Kubernetes Service Account
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::${aws_iam_role.fsx.arn}:role/fsx-csi-controller-sa"
    }
  }
}

resource "kubernetes_cluster_role" "fsx_csi_external_provisioner" {
  metadata {
    name = "fsx-csi-external-provisioner-role"
  }
  rule {
    api_groups = [""]
    resources  = ["persistentvolumes"]
    verbs      = ["get", "list", "watch", "create", "delete"]
  }
  rule {
    api_groups = [""]
    resources  = ["persistentvolumeclaims"]
    verbs      = ["get", "list", "watch", "update"]
  }
  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["list", "watch", "create", "update", "patch"]
  }
  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["csinodes"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["get", "watch", "list", "delete", "update", "create"]
  }
}

resource "kubernetes_cluster_role_binding" "fsx_csi_external_provisioner" {
  metadata {
    name = "fsx-csi-external-provisioner-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "fsx-csi-external-provisioner-role"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "fsx-csi-controller-sa"
    namespace = "kube-system"
  }
}

## CSI Driver for FSx
## From https://github.com/kubernetes-sigs/aws-fsx-csi-driver/blob/master/deploy/kubernetes/base/csidriver.yaml
resource "kubernetes_csi_driver" "fsx" {
  metadata {
    name = "fsx.csi.aws.com"
  }
  spec {
    attach_required = false
    volume_lifecycle_modes = ["Persistent"]
  }
}

## Secret to hold aws access key and secret key
## From https://github.com/kubernetes-sigs/aws-fsx-csi-driver/blob/master/deploy/kubernetes/secret.yaml
resource "kubernetes_secret" "aws" {
  metadata {
    name      = "aws-secret"
    namespace = "kube-system"
  }
  data = {
    key_id     = var.aws_access_key
    access_key = var.aws_secret_key
  }
}

## Run FSx controller
## From https://github.com/kubernetes-sigs/aws-fsx-csi-driver/blob/master/deploy/kubernetes/base/controller.yaml
resource "kubernetes_deployment" "fsx_csi_controller" {
  metadata {
    name      = "fsx-csi-controller"
    namespace = "kube-system"
  }
 
  spec {
    replicas = 2
    
    selector {
      match_labels = {
        app = "fsx-csi-controller"
      }
    }
    template {
      metadata {
        labels = {
          app = "fsx-csi-controller"
        }
      }
      spec {
        node_selector = {
          "kubernetes.io/os"   = "linux"
          "kubernetes.io/arch" = "amd64"
        }
        service_account_name = "fsx-csi-controller-sa"
        priority_class_name  = "system-cluster-critical"
        toleration {
          key      = "CriticalAddonsOnly"
          operator = "Exists"
        }
        container {
          image = "amazon/aws-fsx-csi-driver:v0.4.0"
          name  = "fsx-plugin"

          args = [
            "--endpoint=$(CSI_ENDPOINT)",
            "--logtostderr",
            "--v=5"
          ]
          env {
            name  = "CSI_ENDPOINT"
            value = "unix:///var/lib/csi/sockets/pluginproxy/csi.sock"
          }
          env {
            name = "AWS_ACCESS_KEY_ID"
            value_from {
              secret_key_ref {
                key      = "key_id"
                name     = "aws-secret"
                optional = true
              }
            }
          }
          env {
            name = "AWS_SECRET_ACCESS_KEY"
            value_from {
              secret_key_ref {
                key      = "access_key"
                name     = "aws-secret"
                optional = true
              }
            }
          }
          volume_mount {
            name       = "socket-dir"
            mount_path = "/var/lib/csi/sockets/pluginproxy/"
          }
        }
        container {
          image = "quay.io/k8scsi/csi-provisioner:v1.3.0"
          name  = "csi-provisioner"

          args = [
            "--timeout=5m",
            "--csi-address=$(ADDRESS)",
            "--v=5",
            "--enable-leader-election",
            "--leader-election-type=leases"
          ]
          env {
            name  = "ADDRESS"
            value = "/var/lib/csi/sockets/pluginproxy/csi.sock"
          }
          volume_mount {
            name       = "socket-dir"
            mount_path = "/var/lib/csi/sockets/pluginproxy/"
          }
        }
        volume {
          name = "socket-dir"
          empty_dir {}
        }
      }
    }
  }
}

## DaemonSet runs fsx driver on every compatible node
## From https://github.com/kubernetes-sigs/aws-fsx-csi-driver/blob/master/deploy/kubernetes/base/node.yaml
resource "kubernetes_daemonset" "fsx_csi_node" {
  metadata {
    name      = "fsx-csi-node"
    namespace = "kube-system"
  }
  spec {
    selector {
      match_labels = {
        app = "fsx-csi-node"
      }
    }
    template {
      metadata {
        labels = {
          app = "fsx-csi-node"
        }
      }
      spec {
        node_selector = {
          "kubernetes.io/os"   = "linux"
          "kubernetes.io/arch" = "amd64"
        }
        host_network = true
        
        container {
          args = [
            "--endpoint=$(CSI_ENDPOINT)",
            "--logtostderr",
            "--v=5"
          ]

          image = "amazon/aws-fsx-csi-driver:v0.4.0"
          name  = "fsx-plugin"

          env {
            name  = "CSI_ENDPOINT"
            value = "unix:/csi/csi.sock"
          }
          liveness_probe {
            failure_threshold = 5

            initial_delay_seconds = 10
            period_seconds        = 2
            timeout_seconds       = 3

            http_get {
              path = "/healthz"
              port = "healthz"
            }
          }
          port {
            container_port = 9810
            host_port      = 9810
            name           = "healthz"
            protocol       = "TCP"
          }
          security_context {
            privileged = true
          }
          volume_mount {
            mount_path        = "/var/lib/kubelet"
            mount_propagation = "Bidirectional"
            name              = "kubelet-dir"
          }
          volume_mount {
            mount_path = "/csi"
            name       = "plugin-dir"
          }
        }
        container {
          image = "quay.io/k8scsi/csi-node-driver-registrar:v1.1.0"
          name  = "csi-driver-registrar"

          args = [
            "--csi-address=$(ADDRESS)",
            "--kubelet-registration-path=$(DRIVER_REG_SOCK_PATH)",
            "--v=5"
          ]
          
          env {
            name  = "ADDRESS"
            value = "/csi/csi.sock"
          }
          env {
            name  = "DRIVER_REG_SOCK_PATH"
            value = "/var/lib/kubelet/plugins/fsx.csi.aws.com/csi.sock"
          }
          env {
            name = "KUBE_NODE_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }
          volume_mount {
            mount_path = "/csi"
            name       = "plugin-dir"
          }
          volume_mount {
            mount_path = "/registration"
            name       = "registration-dir"
          }
        }
        container {
          image             = "quay.io/k8scsi/livenessprobe:v1.1.0"
          image_pull_policy = "Always"
          name              = "liveness-probe"
          
          args = [
            "--csi-address=/csi/csi.sock",
            "--health-port=9810"
          ]

          volume_mount {
            mount_path = "/csi"
            name       = "plugin-dir"
          }
        }
        volume {
          name = "kubelet-dir"

          host_path {
            path = "/var/lib/kubelet"
            type = "Directory"
          }
        }
        volume {
          name = "plugin-dir"

          host_path {
            path = "/var/lib/kubelet/plugins/fsx.csi.aws.com/"
            type = "DirectoryOrCreate"
          }
        }
        volume {
          name = "registration-dir"
          
          host_path {
            path = "/var/lib/kubelet/plugins_registry/"
            type = "Directory"
          }
        }
      }
    }
  }
}
