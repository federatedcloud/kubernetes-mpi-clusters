resource "kubernetes_manifest" "mpijob" {
  depends_on = [
    kubernetes_manifest.mpijob_crd,
  ]
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "kubeflow.org/v1"
    "kind" = "MPIJob"
    "metadata" = {
      "name" = var.container_name
      "namespace" = "mpi-operator"
    }
    "spec" = {
      "cleanPodPolicy" = "Running"
      "mpiReplicaSpecs" = {
        "Launcher" = {
          "replicas" = 1
          "template" = {
            "spec" = {
              "containers" = [
                {
                  "command" = [
                    "bash"
                  ]
                  "args" = [
                    "-c",
                    "${file(var.runscript_file)}"
                  ]
                  ## Not sure if this image needs to match Worker image
                  "image" = var.image_id
                  "name" = var.container_name
                  "volumeMounts" = [
                    {
                      "mountPath" = "/opt/wrf/data"
                      "name" = "nfs"
                    },
                  ]
                  "env" = [
                    {
                      "name" = "OMP_STACKSIZE"
                      "value" = "96G"
                    },
                    {
                      "name" = "KMP_STACKSIZE"
                      "value" = "96G"
                    }
                  ]
                }
              ]
              ## Puts launcher pod on launcher node
              "nodeSelector" = {
                "role" = "launcher"
              }
              "volumes" = [
                {
                  "name" = "nfs"
                  "nfs" = {
                    "server" = var.nfs_server_ip
                    "path" = "/"
                  }
                }
              ]
            }
          }
        }
        "Worker" = {
          "replicas" = var.num_workers
          "template" = {
            "spec" = {
              ## Schedule worker pods to different nodes
              "affinity" = {
                "podAntiAffinity" = {
                  "requiredDuringSchedulingIgnoredDuringExecution" = [
                    {
                      "labelSelector" = {
                        "matchExpressions" = [
                          {
                            "key" = "mpi-job-role"
                            "operator" = "In"
                            "values" = [
                              "worker"
                            ]
                          }
                        ]
                      }
                      "topologyKey" = "kubernetes.io/hostname"
                    }
                  ]
                }
              }
              "containers" = [
                {
                  "image" = var.image_id
                  "name" = var.container_name
                  ## Defines which volumes to mount for this container and where
                  "volumeMounts" = [
                    {
                      "mountPath" = "/opt/wrf/data"
                      "name" = "nfs"
                    },
                    {
                      "mountPath" = "/dev/shm"
                      "name" = "dshm"
                    }
                  ]
                  "env" = [                                            
                    {                                                  
                      "name" = "OMP_STACKSIZE"                         
                      "value" = "96G"                                  
                    },                                                 
                    {                                                  
                      "name" = "KMP_STACKSIZE"                          
                      "value" = "96G"                                  
                    }                                                  
                  ]
                }
              ]
              ## Puts worker pods on worker nodes
              "nodeSelector" = {
                "role" = "worker"
              }
              ## Defines which volumes are accessible to the pod
              "volumes" = [
                {
                  "name" = "nfs"
                  "nfs" = {
                    "server" = var.nfs_server_ip
                    "path" = "/"
                  }
                },
                {
                  "name" = "dshm"
                  "emptyDir" = {
                    "medium" = "Memory"
                    "sizeLimit" = "64Gi"
                  }
                }
              ]
            }
          }
        }
      }
      "slotsPerWorker" = var.slots_per_worker
    }
  }
}
