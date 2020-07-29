resource "kubernetes_manifest" "deployment_mpi_operator" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "app" = "mpi-operator"
      }
      "name" = "mpi-operator"
      "namespace" = "mpi-operator"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "app" = "mpi-operator"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "mpi-operator"
          }
        }
        "spec" = {
          "containers" = [
            {
              "args" = [
                "-alsologtostderr",
                "--kubectl-delivery-image",
                "mpioperator/kubectl-delivery:latest",
              ]
              "image" = "mpioperator/mpi-operator:latest"
              "imagePullPolicy" = "Always"
              "name" = "mpi-operator"
            },
          ]
          "serviceAccountName" = "mpi-operator"
        }
      }
    }
  }
}

resource "kubernetes_manifest" "customresourcedefinition_mpijobs_kubeflow_org" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "apiextensions.k8s.io/v1beta1"
    "kind" = "CustomResourceDefinition"
    "metadata" = {
      "name" = "mpijobs.kubeflow.org"
      "namespace" = "default"
    }
    "spec" = {
      "group" = "kubeflow.org"
      "names" = {
        "kind" = "MPIJob"
        "plural" = "mpijobs"
        "shortNames" = [
          "mj",
          "mpij",
        ]
        "singular" = "mpijob"
      }
      "scope" = "Namespaced"
      "subresources" = {
        "status" = {}
      }
      "validation" = {
        "openAPIV3Schema" = {
          "properties" = {
            "spec" = {
              "properties" = {
                "mpiReplicaSpecs" = {
                  "properties" = {
                    "Launcher" = {
                      "properties" = {
                        "replicas" = {
                          "maximum" = 1
                          "minimum" = 1
                          "type" = "integer"
                        }
                      }
                    }
                    "Worker" = {
                      "properties" = {
                        "replicas" = {
                          "minimum" = 1
                          "type" = "integer"
                        }
                      }
                    }
                  }
                }
                "slotsPerWorker" = {
                  "minimum" = 1
                  "type" = "integer"
                }
              }
            }
          }
        }
      }
      "version" = "v1alpha2"
    }
  }
}
