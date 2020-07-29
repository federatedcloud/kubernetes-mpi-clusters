resource "kubernetes_manifest" "clusterrole_mpi_operator" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "name" = "mpi-operator"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "configmaps",
          "serviceaccounts",
        ]
        "verbs" = [
          "create",
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "pods",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "pods/exec",
        ]
        "verbs" = [
          "create",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "endpoints",
        ]
        "verbs" = [
          "create",
          "get",
          "update",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "events",
        ]
        "verbs" = [
          "create",
          "patch",
        ]
      },
      {
        "apiGroups" = [
          "rbac.authorization.k8s.io",
        ]
        "resources" = [
          "roles",
          "rolebindings",
        ]
        "verbs" = [
          "create",
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "policy",
        ]
        "resources" = [
          "poddisruptionbudgets",
        ]
        "verbs" = [
          "create",
          "list",
          "update",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "apps",
        ]
        "resources" = [
          "statefulsets",
        ]
        "verbs" = [
          "create",
          "list",
          "update",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "batch",
        ]
        "resources" = [
          "jobs",
        ]
        "verbs" = [
          "create",
          "list",
          "update",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "apiextensions.k8s.io",
        ]
        "resources" = [
          "customresourcedefinitions",
        ]
        "verbs" = [
          "create",
          "get",
        ]
      },
      {
        "apiGroups" = [
          "kubeflow.org",
        ]
        "resources" = [
          "mpijobs",
          "mpijobs/finalizers",
          "mpijobs/status",
        ]
        "verbs" = [
          "*",
        ]
      },
      {
        "apiGroups" = [
          "scheduling.incubator.k8s.io",
          "scheduling.sigs.dev",
        ]
        "resources" = [
          "queues",
          "podgroups",
        ]
        "verbs" = [
          "*",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "serviceaccount_mpi_operator" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "v1"
    "kind" = "ServiceAccount"
    "metadata" = {
      "name" = "mpi-operator"
      "namespace" = "mpi-operator"
    }
  }
}

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

