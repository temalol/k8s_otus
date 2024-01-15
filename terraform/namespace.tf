resource "kubernetes_namespace" "example" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "kubernetes_namespace" "example" {
  metadata {
    name = "bookinfo"
  }
}