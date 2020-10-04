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
  forwardauth_middleware_namespace = var.name_prefix
  forwardauth_middleware_name      = "forwardauth-authorize"
}

data "kubernetes_namespace" "spinnaker" {
  metadata {
    name = "spinnaker"
  }
}

#####################################################################
# Deploy Aromy Spinnaker Operator in Spinnaker namespace.
####################################################################
resource "helm_release" "helm_release_spinnaker_operator" {
  name       = "spinnaker"
  repository = "https://armory.jfrog.io/artifactory/charts/"
  chart      = "armory-spinnaker-operator"

  #version   = "1.2.0-snapshot.fix.ubi.f9afe37"
  namespace = data.kubernetes_namespace.spinnaker.id
}

# Create Alias A records for Spinnaker
resource "aws_route53_record" "spin_alias_record" {
  zone_id = var.hosted_zone_id
  name    = "spin"
  type    = "A"

  alias {
    name                   = "lb.${var.domain_name}"
    zone_id                = var.hosted_zone_id
    evaluate_target_health = false
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
      "traefik.ingress.kubernetes.io/router.middlewares"      = local.forwardauth_middleware_name
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
      "traefik.ingress.kubernetes.io/router.middlewares"      = local.forwardauth_middleware_name
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