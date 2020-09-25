#####################################################################
# configure spinnaker
#
# TODO
# - add spinnaker terraform provider to create pipelines and stuff
#
####################################################################
locals {
  app_name = "spinnaker"
  labels = merge(var.labels, {
    "app" = local.app_name
  })
}

data "kubernetes_namespace" "spinnaker" {
  metadata {
    name = "spinnaker"
  }
}

resource "kubernetes_ingress" "spinnaker_deck_ingress" {
  metadata {
    name      = "spin-deck"
    namespace = data.kubernetes_namespace.spinnaker.id
    annotations = {
      "kubernetes.io/ingress.class"                           = "traefik-${var.name_prefix}"
      "traefik.ingress.kubernetes.io/router.entrypoints"      = "websecure"
      "traefik.ingress.kubernetes.io/router.tls.certresolver" = "default"
      "traefik.ingress.kubernetes.io/router.middlewares"      = "forwardauth-authorize"
    }
    labels = local.labels
  }

  spec {
    rule {
      host = "spin.${var.domain_name}"
      http {
        path {
          backend {
            service_name = "spin-deck"
            service_port = 9000
          }
        }
      }
    }
  }
}


resource "kubernetes_ingress" "spinnaker_gate_ingress" {
  metadata {
    name      = "spin-gate"
    namespace = data.kubernetes_namespace.spinnaker.id
    annotations = {
      "kubernetes.io/ingress.class"                           = "traefik-${var.name_prefix}"
      "traefik.ingress.kubernetes.io/router.entrypoints"      = "websecure"
      "traefik.ingress.kubernetes.io/router.tls.certresolver" = "default"
      "traefik.ingress.kubernetes.io/router.middlewares"      = "${var.name_prefix}-forwardauth-authorize@kubernetescrd,api-stripprefix@file"
    }
    labels = local.labels
  }

  spec {
    rule {
      host = "spin.${var.domain_name}"
      http {
        path {
          backend {
            service_name = "spin-gate"
            service_port = 8084
          }
          path = "/api"
        }
      }
    }
  }
}