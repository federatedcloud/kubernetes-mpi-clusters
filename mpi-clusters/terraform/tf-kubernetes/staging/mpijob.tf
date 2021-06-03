resource "kubernetes_manifest" "mpijob_hpl_benchmarks" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "kubeflow.org/v1alpha2"
    "kind" = "MPIJob"
    "metadata" = {
      "name" = var.container_name
      "namespace" = "default"
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
# Syntax might not work with newer versions
                  "command" = [
                    "su",
                    "nixuser",
                    "-c",
                    "nix-shell dev.nix --run \"cd ~; ${var.runscript}\""
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
                    "limits" = null
                  }
                },
              ]
            }
          }
        }
      }
      "slotsPerWorker" = var.slots_per_worker
    }
  }
}
