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
            }
          }
        }
        "Worker" = {
          "replicas" = var.num_workers
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
                      "cpu" = "4"
                      "memory" = "15G"
                    }
                    ## Set requests to be just over half of cpu, memory per node
                    "requests" = {
                      "cpu" = "2500m"
                      "memory" = "10G"
                    }
                  }
                  ## Defines which volumes to mount for this container and where
                  "volumeMounts" = [
                    {
                      "mountPath" = "/home/nixuser/HPL.dat"
                      "name" = "cfgmap"
                      "subPath" = "HPL.dat"
                    }
                  ]
                },
              ]
              ## Defines which volumes are accessible to the pod
              "volumes" = [
                {
                  "name" = "cfgmap"
                  "configMap" = {
                    "name" = "cfgmap-file-mount"
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
