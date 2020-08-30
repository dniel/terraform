locals {
  app_name = "traefik"
  labels = merge(var.labels, {
    "app" = local.app_name
  })
  forwardauth_middleware_namespace = var.name_prefix
  forwardauth_middleware_name      = "${local.forwardauth_middleware_namespace}-forwardauth-authorize@kubernetescrd"
}

data "helm_repository" "dniel" {
  name = "dniel"
  url  = "https://dniel.github.com/charts"
}

data "helm_repository" "traefik" {
  name = local.app_name
  url  = "https://containous.github.io/traefik-helm-chart"
}

resource "helm_release" "traefik" {
  name       = local.app_name
  repository = data.helm_repository.dniel.id
  chart      = local.app_name

  #  version   = var.traefik_helm_release_version
  namespace = var.namespace.id

  skip_crds = true
  set {
    name  = "rbac.create"
    value = "false"
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
    value = "false"
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
    name  = "ingressroute.middlewares[0].name"
    value = local.forwardauth_middleware_name
  }
  set {
    name  = "ingressroute.middlewares[0].namespace"
    value = local.forwardauth_middleware_namespace
  }
  set {
    name  = "additionalArguments"
    value = "{--log.level=DEBUG,--providers.kubernetesingress,--providers.file.filename=/config/dynamic.yml,--configFile=/config/static.yml}"
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
    "static.yml" = templatefile("${path.module}/templates/static.tpl", {
      app_name    = local.app_name,
      domain_name = var.domain_name,
      name_prefix = var.name_prefix
    })
  }
}

resource "kubernetes_manifest" "ingressroute_traefik_dashboard" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind" = "IngressRoute"
    "metadata" = {
      "annotations" = {
        "kubernetes.io/ingress.class" = "traefik-${var.name_prefix}"
      },
      "namespace" = var.namespace.id
      "labels" = local.labels
      "name" = "traefik-dashboard"
    }
    "spec" = {
      "entryPoints" = [
        "websecure",
      ]
      "routes" = [
        {
          "kind" = "Rule"
          "match" = "Host(`traefik.${var.domain_name}`)"
          "middlewares" = [
            {
              "name" = "${var.name_prefix}-forwardauth-authorize@kubernetescrd"
              "namespace" = "${var.name_prefix}"
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