resource "kubernetes_namespace" "mpi_operator" {
  metadata {
    name = "mpi-operator"
  }
}
