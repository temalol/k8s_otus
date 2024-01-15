resource "kubernetes_namespace" "example" {
  metadata {
    name = "ingress-nginx"
  }
}