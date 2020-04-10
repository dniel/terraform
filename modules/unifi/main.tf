locals {
  labels = merge(var.labels, {
    "app" = "unifi"
  })
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "kubernetes_namespace" "unifi" {
  metadata {
    name   = "${var.name_prefix}-unifi"
    labels = local.labels
  }
}

resource "helm_release" "unifi" {
  name       = "unifi"
  repository = data.helm_repository.stable.id
  chart      = "unifi"
  version    = var.unifi_helm_release_version
  namespace  = kubernetes_namespace.unifi.id
}

resource "kubernetes_ingress" "unifi_gui_ingress" {
  metadata {
    name      = "unifi-gui"
    namespace = kubernetes_namespace.unifi.id
    annotations = {
      "kubernetes.io/ingress.class"                           = "traefik-${var.name_prefix}"
      "traefik.ingress.kubernetes.io/router.entrypoints"      = "websecure"
      "traefik.ingress.kubernetes.io/router.tls.certresolver" = "default"
      "traefik.ingress.kubernetes.io/router.middlewares"      = "forwardauth@file"
    }
    labels = local.labels
  }

  spec {
    rule {
      host = "ubnt.${var.domain_name}"
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
    namespace = kubernetes_namespace.unifi.id
    annotations = {
      "kubernetes.io/ingress.class"                           = "traefik-${var.name_prefix}"
      "traefik.ingress.kubernetes.io/router.entrypoints"      = "websecure"
      "traefik.ingress.kubernetes.io/router.tls.certresolver" = "default"
    }
    labels = local.labels
  }

  spec {
    rule {
      host = "ubnt.${var.domain_name}"
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
