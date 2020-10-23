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

resource "kubernetes_manifest" "middleware_strip_api_prefix" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" : "traefik.containo.us/v1alpha1"
    "kind" : "Middleware"
    "metadata" : {
      "labels" : local.labels
      "namespace" : "spinnaker"
      "name" : "strip-api-prefix"
    }
    "spec" : {
      "stripPrefix" : {
        "prefixes" : [
          "/api"
        ]
      }
    }
  }
}

######################################################
# expose spinnaker api
#
######################################################
resource "kubernetes_manifest" "spinnaker_gate_ingressroute" {
  provider   = kubernetes-alpha

  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "annotations" = {
        "kubernetes.io/ingress.class" = "traefik-${var.name_prefix}"
      },
      "namespace" = "spinnaker"
      "labels"    = local.labels
      "name"      = "spin-gate"
    }
    "spec" = {
      "entryPoints" = [
        "websecure",
      ]
      "routes" = [
        {
          "kind"  = "Rule"
          "match" = "Host(`spin.${var.domain_name}`) && PathPrefix(`/api`)"
          "middlewares" = [
            {
              "name"      = "strip-api-prefix"
              "namespace" = "spinnaker"
            },
          ]
          "services" = [
            {
              "name" = "spin-gate"
              "port" = 8084
            },
          ]
        },
      ]
      "tls" = {
        "certResolver" = "default"
      }
    }
  }
}

######################################################
# expose spinnaker ui
#
######################################################
resource "kubernetes_manifest" "spinnaker_deck_ingressroute" {
  provider   = kubernetes-alpha

  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "annotations" = {
        "kubernetes.io/ingress.class" = "traefik-${var.name_prefix}"
      },
      "namespace" = "spinnaker"
      "labels"    = local.labels
      "name"      = "spin-deck"
    }
    "spec" = {
      "entryPoints" = [
        "websecure",
      ]
      "routes" = [
        {
          "kind"  = "Rule"
          "match" = "Host(`spin.${var.domain_name}`)"
          "middlewares" = [
          ]
          "services" = [
            {
              "name" = "spin-deck"
              "port" = 9000
            },
          ]
        },
      ]
      "tls" = {
        "certResolver" = "default"
      }
    }
  }
}
