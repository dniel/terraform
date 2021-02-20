######################################################
# create ingress route with middleware for Traefik Dashboard
locals {
  labels = merge(var.labels, {
  })
  forwardauth_middleware_namespace = var.name_prefix
  forwardauth_middleware_name      = "forwardauth-authorize"
}

######################################################
# Install kube-prometheus-stack containing
# - grafana
# - prometheus
# - alertmanager
# - ++
#
######################################################
resource "kubernetes_manifest" "kube_prometheus_stack" {
  provider = kubernetes-alpha

  manifest = {
    "apiVersion" = "helm.fluxcd.io/v1"
    "kind"       = "HelmRelease"
    "metadata" = {
      "namespace" = var.name_prefix
      "name"      = "kube-prometheus-stack"
    }
    "spec" = {
      "chart" = {
        "repository" = "https://prometheus-community.github.io/helm-charts"
        "name"       = "kube-prometheus-stack"
        "version"    = "13.4.1"
      }
    }
  }
}

######################################################
# Create Alias A records for grafana
#
######################################################
module "grafana_alias_record" {
  source = "../../dns-cname-record"

  alias_name     = "grafana"
  alias_target   = "lb.${var.domain_name}"
  domain_name    = var.domain_name
  hosted_zone_id = var.hosted_zone_id
  labels         = local.labels
  name_prefix    = var.name_prefix
}

######################################################
# expose Grafana.
#
######################################################
resource "kubernetes_manifest" "ingressroute_grafana" {
  provider = kubernetes-alpha

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
              "name" = "services-kube-prometheus-stack-grafana"
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
# Create Alias A records for prometheus
#
######################################################
module "prometheus_alias_record" {
  source = "../../dns-cname-record"

  alias_name     = "prometheus"
  alias_target   = "lb.${var.domain_name}"
  domain_name    = var.domain_name
  hosted_zone_id = var.hosted_zone_id
  labels         = local.labels
  name_prefix    = var.name_prefix
}
######################################################
# expose Prometheus.
#
######################################################
resource "kubernetes_manifest" "ingressroute_prometheus" {
  provider = kubernetes-alpha

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