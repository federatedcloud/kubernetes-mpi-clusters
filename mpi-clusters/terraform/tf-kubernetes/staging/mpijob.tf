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
                  "command" = [
                    "su",
                    "nixuser",
                    "-c",
                    "nix-shell dev.nix --run 'cd ~; ${var.runscript}'"
                  ]
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
                  "resources" = {
                    "limits" = {
                      "cpu" = "4"
                      "memory" = "15G"
                    }
                    "requests" = {
                      "cpu" = "2500m"
                      "memory" = "10G"
                    }
                  }
                  "volumeMounts" = [
                    {
                      "mountPath" = "/home/nixuser/HPL.dat"
                      "name" = "cfgmap"
                      "subPath" = "HPL.dat"
                    }
                  ]
                },
              ]
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
