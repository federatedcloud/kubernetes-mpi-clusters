resource "kubernetes_manifest" "mpijob_hpl_benchmarks" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "kubeflow.org/v1alpha2"
    "kind" = "MPIJob"
    "metadata" = {
      "name" = "hpl-benchmarks"
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
                  "command" = [
                    "su",
                    "nixuser",
                    "-c",
                    "nix-shell dev.nix --run \"sleep 60; cd ~; mpirun -np 4 --bind-to core --map-by slot xhpl\""
                  ]
                  "image" = "cornellcac/nix-mpi-benchmarks:a4f3cd63f6994703bbaa0636f4ddbcc87e83ea05"
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
                  "image" = "cornellcac/nix-mpi-benchmarks:a4f3cd63f6994703bbaa0636f4ddbcc87e83ea05"
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
