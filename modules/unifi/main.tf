locals {
  dns_name = "unifi.${var.domain_name}"
  labels = merge(var.labels, {
    "app" = "unifi"
  })
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "unifi" {
  name       = "unifi"
  repository = data.helm_repository.stable.id
  chart      = "unifi"
  version    = var.unifi_helm_release_version
  namespace  = var.namespace.id
}

resource "kubernetes_ingress" "unifi_gui_ingress" {
  metadata {
    name      = "unifi-gui"
    namespace = var.namespace.id
    annotations = {
      "kubernetes.io/ingress.class"                           = "traefik-${var.name_prefix}"
      "traefik.ingress.kubernetes.io/router.entrypoints"      = "websecure"
      "traefik.ingress.kubernetes.io/router.tls.certresolver" = "default"
    }
    labels = local.labels
  }

  spec {
    rule {
      host = local.dns_name
      http {
        path {
          backend {
            service_name = "unifi-gui"
            service_port = "https-gui"
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress" "unifi_inform_ingress" {
  metadata {
    name      = "unifi-inform"
    namespace = var.namespace.id
    annotations = {
      "kubernetes.io/ingress.class"                      = "traefik-${var.name_prefix}"
      "traefik.ingress.kubernetes.io/router.entrypoints" = "web"
      #      "traefik.ingress.kubernetes.io/router.tls.certresolver" = "default"
    }
    labels = local.labels
  }

  spec {
    rule {
      host = local.dns_name
      http {
        path {
          path = "/inform"
          backend {
            service_name = "unifi-controller"
            service_port = "controller"
          }
        }
      }
    }
  }
}
