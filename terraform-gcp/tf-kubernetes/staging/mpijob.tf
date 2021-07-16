resource "kubernetes_manifest" "mpijob" {
  depends_on = [
    kubernetes_manifest.mpijob_crd,
    kubernetes_config_map.file_mount
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
                  ## Ensures commands are running in proper environment
                  ## May want to change the last line
                  "command" = [
                    "su",
                    "nixuser",
                    "-c",
                    "nix-shell dev.nix --run 'cd ~; ${var.runscript}'"
                  ]
                  ## Not sure if this image needs to match Worker image
                  "image" = var.image_id
                  "name" = var.container_name
                },
              ]
              "nodeSelector" = {
                "role" = "launcher"
              }
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
                      "mountPath" = "/home/nixuser/HPL.dat"
                      "name" = "cfgmap"
                      "subPath" = "HPL.dat"
                    },
                    {
                      "mountPath" = "/dev/shm"
                      "name" = "dshm"
                    }
                  ]
                },
              ]
              "nodeSelector" = {
                "role" = "worker"
              }
              ## Defines which volumes are accessible to the pod
              "volumes" = [
                {
                  "name" = "cfgmap"
                  "configMap" = {
                    "name" = "cfgmap-file-mount"
                  }
                },
                {
                  "name" = "dshm"
                  "emptyDir" = {
                    "medium" = "Memory"
                    "sizeLimit" = "11Gi"
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
