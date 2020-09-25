locals {
  app_name = "traefik"
  labels = merge(var.labels, {
    "app" = local.app_name
  })
  forwardauth_middleware_namespace = var.name_prefix
  forwardauth_middleware_name      = "forwardauth-authorize"
}

data "kubernetes_namespace" "env_namespace" {
  metadata {
    name = var.name_prefix
  }
}

resource "helm_release" "traefik" {
  name       = local.app_name
  repository = "https://helm.traefik.io/traefik"
  chart      = local.app_name

  version   = var.traefik_helm_release_version
  namespace = var.namespace.id

  skip_crds = true
  set {
    name  = "pilot.enabled"
    value = "${length(var.traefik_pilot_token) > 0}"
  }
  set {
    name  = "pilot.token"
    value = var.traefik_pilot_token
  }
  set {
    name  = "rbac.create"
    value = "true"
  }
  set {
    name  = "rbac.namespaced"
    value = "true"
  }
  set {
    name  = "serversTransport.insecureSkipVerify"
    value = "true"
  }
  set {
    name  = "service.type"
    value = var.traefik_service_type
  }
  set {
    name  = "ports.traefik.expose"
    value = "false"
  }
  set {
    name  = "ports.web.expose"
    value = "true"
  }
  set {
    name  = "ports.websecure.nodePort"
    value = var.traefik_websecure_port
  }
  set {
    name  = "volumes[0].name"
    value = "traefik-default-tls"
  }
  set {
    name  = "volumes[0].mountPath"
    value = "/ssl"
  }
  set {
    name  = "volumes[0].type"
    value = "secret"
  }
  set {
    name  = "volumes[1].name"
    value = "traefik"
  }
  set {
    name  = "volumes[1].mountPath"
    value = "/config"
  }
  set {
    name  = "volumes[1].type"
    value = "configMap"
  }
  set {
    name  = "ingressRoute.dashboard.enabled"
    value = "false"
  }
  set {
    name  = "additionalArguments[0]"
    value = "--providers.kubernetesingress.ingressclass=traefik-${var.name_prefix}"
  }
  set {
    name  = "additionalArguments[1]"
    value = "--providers.kubernetesCRD.ingressclass=traefik-${var.name_prefix}"
  }
  set {
    name  = "additionalArguments[2]"
    value = "--providers.file.filename=/config/dynamic.yml"
  }
  set {
    name  = "additionalArguments[3]"
    value = "--providers.kubernetesingress.namespaces=${var.name_prefix}"
  }
  set {
    name  = "additionalArguments[4]"
    value = "--providers.kubernetesCRD.namespaces=${var.name_prefix}"
  }
}

resource "kubernetes_config_map" "traefik" {
  metadata {
    name      = local.app_name
    namespace = var.namespace.id
    labels    = local.labels
  }

  data = {
    "dynamic.yml" = templatefile("${path.module}/templates/dynamic.tpl", {
      app_name    = local.app_name,
      domain_name = var.domain_name,
      name_prefix = var.name_prefix
    })
  }
}

resource "kubernetes_manifest" "middleware_strip_api_prefix" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" : "traefik.containo.us/v1alpha1"
    "kind" : "Middleware"
    "metadata" : {
      "labels" : local.labels
      "namespace" : var.namespace.id
      "name" : "strip-api-prefix"
    }
    "spec" : {
      "stripPrefix" : {
        "prefixes" : [
          "/api",
        ]
      }
    }
  }
}

# create ingress route with middleware for Traefik Dashboard
resource "kubernetes_manifest" "ingressroute_traefik_dashboard" {
  depends_on = [helm_release.traefik]
  provider   = kubernetes-alpha

  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "annotations" = {
        "kubernetes.io/ingress.class" = "traefik-${var.name_prefix}"
      },
      "namespace" = var.namespace.id
      "labels"    = local.labels
      "name"      = "traefik-dashboard"
    }
    "spec" = {
      "entryPoints" = [
        "websecure",
      ]
      "routes" = [
        {
          "kind"  = "Rule"
          "match" = "Host(`traefik.${var.domain_name}`)"
          "middlewares" = [
            {
              "name"      = local.forwardauth_middleware_name
              "namespace" = local.forwardauth_middleware_namespace
            },
          ]
          "services" = [
            {
              "kind" = "TraefikService"
              "name" = "api@internal"
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
