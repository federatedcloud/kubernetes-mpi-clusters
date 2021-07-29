## Creates namespace to put all mpi-operator resources in
resource "kubernetes_namespace" "mpi_operator" {
  depends_on = [ kubernetes_config_map.aws_auth ]
  metadata {
    name = "mpi-operator"
  }
}

## Sets up permissions for mpi-operator resources
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
          "update",
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
          "create",
          "get",
          "list",
          "watch",
          "delete",
          "update",
          "patch",
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
          "update",
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
          "scheduling.volcano.sh",
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

## Connects resources to the associated permissions
resource "kubernetes_manifest" "serviceaccount_mpi_operator" {
  depends_on = [
    kubernetes_namespace.mpi_operator
  ]
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
  depends_on = [
    kubernetes_namespace.mpi_operator
  ]
  manifest = {                                                    
    "apiVersion" = "rbac.authorization.k8s.io/v1"                 
    "kind" = "ClusterRoleBinding"                                 
    "metadata" = {                                                
      "name" = "mpi-operator"                                     
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

## Defines the MPIJob resource
resource "kubernetes_manifest" "mpijob_crd" {
  depends_on = [
    kubernetes_namespace.mpi_operator
  ]
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "apiextensions.k8s.io/v1beta1"
    "kind" = "CustomResourceDefinition"
    "metadata" = {
      "name" = "mpijobs.kubeflow.org"
    }
    "spec" = {
      "additionalPrinterColumns" = [
        {
          "JSONPath" = ".metadata.creationTimestamp"
          "name" = "Age"
          "type" = "date"
        },
      ]
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
      ## Currently necessary to allow for the variety of configuration options
      "preserveUnknownFields" = "true"
      "validation" = {
        "openAPIV3Schema" = {
          "type" = "object"
          "properties" = {
            "spec" = {
              "type" = "object"
              "properties" = {
                "mpiReplicaSpecs" = {
                  "type" = "object"
                  "properties" = {
                    "Launcher" = {
                      "type" = "object"
                      "properties" = {
                        "replicas" = {
                          "maximum" = 1
                          "minimum" = 1
                          "type" = "integer"
                        }
                      }
                    }
                    "Worker" = {
                      "type" = "object"
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
      "version" = "v1"
    }
  }
}

## Manages creation of MPIJobs
resource "kubernetes_manifest" "deployment_mpi_operator" {
  depends_on = [
    kubernetes_manifest.serviceaccount_mpi_operator
  ]
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
                "mpioperator/kubectl-delivery:v0.2.3",
                "--namespace",
                "mpi-operator",
                "--lock-namespace",
                "mpi-operator",
              ]
              "command" = [
                "/opt/mpi-operator.v1",
              ]
              "image" = "mpioperator/mpi-operator:v0.2.3"
              "imagePullPolicy" = "Always"
              "name" = "mpi-operator"
            },
          ]
          "serviceAccountName" = "mpi-operator"
          ## Puts mpi-operator pod on launcher node
          "nodeSelector" = {
            "role" = "launcher"
          }
        }
      }
    }
  }
}
