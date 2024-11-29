resource "kubernetes_persistent_volume" "wordpress_mariadb_pv" {
  metadata {
    name = "${var.wordpress_namespace}-wordpress-mariadb-pv"
  }
  spec {
    capacity = {
      storage = var.wordpress_mariadb_storage
    }
    volume_mode                      = "Filesystem"
    access_modes                     = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "local-path"
    persistent_volume_source {
      host_path {
        path = var.wordpress_mariadb_pvc_host_path
        type = "DirectoryOrCreate"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "wordpress_mariadb_pvc" {
  depends_on = [kubernetes_persistent_volume.wordpress_mariadb_pv]
  metadata {
    name      = "wordpress-mariadb-pvc"
    namespace = var.wordpress_namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.wordpress_mariadb_storage
      }
    }
    volume_name        = "${var.wordpress_namespace}-wordpress-mariadb-pv"
    storage_class_name = "local-path"
  }
}

resource "kubernetes_persistent_volume" "wordpress_pv" {
  metadata {
    name = "${var.wordpress_namespace}-wordpress-pv"
  }
  spec {
    capacity = {
      storage = var.wordpress_storage
    }
    volume_mode                      = "Filesystem"
    access_modes                     = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "local-path"
    persistent_volume_source {
      host_path {
        path = var.wordpress_pvc_host_path
        type = "DirectoryOrCreate"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "wordpress_pvc" {
  depends_on = [kubernetes_persistent_volume.wordpress_pv]
  metadata {
    name      = "wordpress-pvc"
    namespace = var.wordpress_namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.wordpress_storage
      }
    }
    volume_name        = "${var.wordpress_namespace}-wordpress-pv"
    storage_class_name = "local-path"
  }
}

resource "kubernetes_manifest" "traefik_redirect" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "Middleware"
    "metadata" = {
      "name"      = "redirect"
      "namespace" = var.wordpress_namespace
    }
    "spec" = {
      "redirectScheme" = {
        "scheme"    = "https"
        "permanent" = true
      }
    }
  }
}

resource "kubernetes_manifest" "traefik_hsts" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "Middleware"
    "metadata" = {
      "name"      = "hsts"
      "namespace" = var.wordpress_namespace
    }
    "spec" = {
      "headers" = {
        "stsSeconds"           = 15552000
        "stsIncludeSubdomains" = true
        "stsPreload"           = true
      }
    }
  }
}

resource "helm_release" "wordpress" {
  depends_on = [
    kubernetes_manifest.traefik_redirect,
    kubernetes_manifest.traefik_hsts,
    kubernetes_persistent_volume_claim.wordpress_pvc,
    kubernetes_persistent_volume_claim.wordpress_mariadb_pvc
  ]
  name       = "wordpress"
  chart      = "wordpress"
  repository = "https://charts.bitnami.com/bitnami"
  namespace  = var.wordpress_namespace
  version    = "24.0.4"
  wait       = false

  values = [
    yamlencode({
      wordpressUsername = var.wordpress_username
      wordpressPassword = var.wordpress_password
      initContainers = [
        {
          name  = "volume-permissions"
          image = "bitnami/minideb"
          command : ["sh", "-c", "chown 1001:1001 /bitnami/wordpress"]
          volumeMounts = [{
            mountPath = "/bitnami/wordpress"
            name      = "wordpress-data"
            subPath   = "wordpress"
          }]
        }
      ]
      ingress = {
        enabled = true
        annotations = {
          "kubernetes.io/ingress.class"                      = "traefik"
          "cert-manager.io/cluster-issuer"                   = var.cert_issuer
          "traefik.ingress.kubernetes.io/router.middlewares" = "${var.wordpress_namespace}-redirect@kubernetescrd,${var.wordpress_namespace}-hsts@kubernetescrd"
        }
        hostname = var.wordpress_host
        tls      = true
      }
      persistence = {
        enabled       = true
        existingClaim = "wordpress-pvc"
      }
      mariadb = {
        enabled = true
        primary = {
          persistence = {
            existingClaim = "wordpress-mariadb-pvc"
          }
        }
        volumePermissions = {
          enabled = true
        }
      }
    })
  ]
  timeout           = 300
  dependency_update = true
}
