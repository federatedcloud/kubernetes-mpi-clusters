resource "kubernetes_manifest" "clusterrolebinding_mpi_operator" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "name" = "mpi-operator"
      "namespace" = "mpi-operator"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "mpi-operator"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "mpi-operator"
        "namespace" = "mpi-operator"
      },
    ]
  }
}

resource "kubernetes_service_account" "mpi_operator" {
  metadata {
    name = "mpi-operator"
    namespace = "mpi-operator"
  }
}

resource "kubernetes_cluster_role" "mpi-operator" {
  metadata {
    name = "mpi-operator"
  }
  rule {
    api_groups = [""]
    resources  = ["configmaps", "serviceaccounts"]
    verbs      = ["create", "list", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods/exec"]
    verbs      = ["create"]
  }
  rule {
    api_groups = [""]
    resources  = ["endpoints"]
    verbs      = ["create", "get", "update"]
  }
  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["create", "patch"]
  }
  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["roles", "rolebindings"]
    verbs      = ["create", "list", "watch"]
  }
  rule {
    api_groups = ["policy"]
    resources  = ["poddisruptionbudgets"]
    verbs      = ["create", "list", "update", "watch"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["statefulsets"]
    verbs      = ["create", "list", "update", "watch"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["jobs"]
    verbs      = ["create", "list", "update", "watch"]
  }
  rule {
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
    verbs      = ["create", "get"]
  }
  rule {
    api_groups = ["kubeflow.org"]
    resources  = ["mpijobs", "mpijobs/finalizers", "mpijobs/status"]
    verbs      = ["*"]
  }
  rule {
    api_groups = ["scheduling.incubator.k8s.io", "scheduling.sigs.dev"]
    resources  = ["queues", "podgroups"]
    verbs      = ["*"]
  }
}
