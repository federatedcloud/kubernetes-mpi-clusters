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
        ## Consider using NodeAffinity and second node pool to free resources
        "Launcher" = {
          "replicas" = 1
          "template" = {
            "spec" = {
              "containers" = [
                {
                  ## Ensures commands are running in proper environment
                  ## May want to change the last line
                  "command" = [
                  #  "su",
                  #  "nixuser",
                  #  "-c",
                  #  "nix-shell dev.nix --run 'cd ~; ${var.runscript}'"
                  #  "bash -c '${var.runscript}'"
                    "bash"
                  ]
                  "args" = [
                    "-c",
                    "${var.runscript}"
                  ]
                  ## Not sure if this image needs to match Worker image
                  "image" = var.image_id
                  "name" = var.container_name
                  "volumeMounts" = [
                    {
                      "mountPath" = "/wrf/data"
                      "name" = "nfs"
                    },
                  ]
                  "resources" = {
                    "requests" = {
                      "cpu" = "1100m"
                      "memory" = "2500M"
                    }
                  }
                }
              ]
              "volumes" = [
                {
                  "name" = "nfs"
                  "nfs" = {
                    "server" = "172.20.102.211"
                    "path" = "/"
                  }
                }
              ]
            }
          }
        }
        "Worker" = {
          ## 2 because mpi images are too bif
          "replicas" = 2
          "template" = {
            "spec" = {
              "containers" = [
                {
                  "image" = var.image_id
                  "name" = var.container_name
                  ## Ensure one worker pod per node
                  "resources" = {
                    ## Set limits to be the maximum cpu, memory per node
                    "limits" = {
                      "cpu" = "2"
                      "memory" = "4G"
                    }
                    ## Set requests to be just over half of cpu, memory per node
                    "requests" = {
                      "cpu" = "1100m"
                      "memory" = "1500M"
                    }
                  }
                  ## Defines which volumes to mount for this container and where
                  "volumeMounts" = [
                    {
                      "mountPath" = "/wrf/data"
                      "name" = "nfs"
                    },
                    {
                      "mountPath" = "/root/${var.remote_file_name}"
                      "name" = "cfgmap"
                      "subPath" = var.remote_file_name
                    }
                  ]
                },
              ]
              #"initContainers" = [
              #  {
              #   "image" = var.image_id
              #   "name" = "wrf-init"
              #   "volumeMounts" = [
              #     {
              #       "mountPath" = "/wrf/data"
              #       "name" = "nfs"
              #     },
              #     {
              #       "mountPath" = "/root/${var.remote_file_name}"
              #       "name" = "cfgmap"
              #       "subPath" = var.remote_file_name
              #     }
              #   ]
              #   "command" = [
              #     "bash",
              #     "-c",
              #     "source /root/${var.remote_file_name}"
              #   ]
              # }
              #}
              ## Defines which volumes are accessible to the pod
              "volumes" = [
                {
                  "name" = "cfgmap"
                  "configMap" = {
                    "name" = "cfgmap-file-mount"
                  }
                },
                {
                  "name" = "nfs"
                  "nfs" = {
                    "server" = "172.20.102.211"
                    "path" = "/"
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
