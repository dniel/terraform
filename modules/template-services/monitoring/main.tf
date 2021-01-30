######################################################
# create ingress route with middleware for Traefik Dashboard

locals {
  labels = merge(var.labels, {
  })
  forwardauth_middleware_namespace = var.name_prefix
  forwardauth_middleware_name      = "forwardauth-authorize"
}

######################################################
# Create Alias A records for grafana
#
######################################################
resource "aws_route53_record" "grafana_alias_record" {
  zone_id = var.hosted_zone_id
  name    = "grafana"
  type    = "A"

  alias {
    name                   = "lb.${var.domain_name}"
    zone_id                = var.hosted_zone_id
    evaluate_target_health = false
  }
}

######################################################
# Create Alias A records for prometheus
#
######################################################
resource "aws_route53_record" "prometheus_alias_record" {
  zone_id = var.hosted_zone_id
  name    = "prometheus"
  type    = "A"

  alias {
    name                   = "lb.${var.domain_name}"
    zone_id                = var.hosted_zone_id
    evaluate_target_health = false
  }
}

######################################################
# expose Grafana.
#
######################################################
resource "kubernetes_manifest" "ingressroute_grafana" {
  provider   = kubernetes-alpha

  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "annotations" = {
        "kubernetes.io/ingress.class" = "traefik-${var.name_prefix}"
      },
      "namespace" = var.name_prefix
      "labels"    = local.labels
      "name"      = "grafana"
    }
    "spec" = {
      "entryPoints" = [
        "websecure",
      ]
      "routes" = [
        {
          "kind"  = "Rule"
          "match" = "Host(`grafana.${var.domain_name}`)"
          "middlewares" = [
            {
              "name"      = local.forwardauth_middleware_name
              "namespace" = local.forwardauth_middleware_namespace
            },
         ]
          "services" = [
            {
              "name" = "prometheus-grafana"
              "port" = 80
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
# expose Prometheus.
#
######################################################
resource "kubernetes_manifest" "ingressroute_prometheus" {
  provider   = kubernetes-alpha

  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "annotations" = {
        "kubernetes.io/ingress.class" = "traefik-${var.name_prefix}"
      },
      "namespace" = var.name_prefix
      "labels"    = local.labels
      "name"      = "prometheus"
    }
    "spec" = {
      "entryPoints" = [
        "websecure",
      ]
      "routes" = [
        {
          "kind"  = "Rule"
          "match" = "Host(`prometheus.${var.domain_name}`)"
          "middlewares" = [
            {
              "name"      = local.forwardauth_middleware_name
              "namespace" = local.forwardauth_middleware_namespace
            },
          ]
          "services" = [
            {
              "name" = "prometheus-operated"
              "port" = 9090
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