resource "kubernetes_manifest" "mpijob_hpl_benchmarks" {
  depends_on = [
    kubernetes_manifest.customresourcedefinition_mpijobs_kubeflow_org
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
                    "nix-shell dev.nix --run 'sleep 10; cd ~; ${var.runscript}'"
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
                      "cpu" = 3
                      "memory" = "10Gi"
                    }
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
