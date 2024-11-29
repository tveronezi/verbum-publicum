resource "kubernetes_namespace" "wordpress" {
  metadata {
    name = var.wordpress_namespace
  }
}
