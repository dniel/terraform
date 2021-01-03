locals {
  app_name = "traefik"
  labels = merge(var.labels, {
    "app" = local.app_name
  })
  forwardauth_middleware_namespace = var.name_prefix
  forwardauth_middleware_name      = "forwardauth-authorize"
}

#############################################
#
#
resource "kubernetes_secret" "route53-credentials" {
  metadata {
    name      = "acme-route53-creds"
    namespace = var.name_prefix
  }
  data = {
    AWS_ACCESS_KEY = var.aws_access_key,
    AWS_SECRET_ACCESS_KEY = var.aws_secret_access_key,
  }
  type = "Opaque"
}

#############################################
#
#
resource "helm_release" "traefik" {
  depends_on = [kubernetes_secret.route53-credentials]
  name       = local.app_name
  repository = "https://helm.traefik.io/traefik"
  chart      = local.app_name

  version   = var.traefik_helm_release_version
  namespace = var.namespace.id

  skip_crds = true
  set {
    name  = "pilot.enabled"
    value = length(var.traefik_pilot_token) > 0
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
    value = "--certificatesresolvers.default.acme.caserver=https://acme-v02.api.letsencrypt.org/directory"
  }
  set {
    name  = "additionalArguments[3]"
    value = "--certificatesresolvers.default.acme.dnsChallenge.provider=route53"
  }
  set {
    name  = "additionalArguments[4]"
    value = "--certificatesResolvers.default.acme.dnsChallenge.delayBeforeCheck=0"
  }
  set {
    name  = "additionalArguments[5]"
    value = "--certificatesresolvers.default.acme.email=daniel@engfeldt.net"
  }
  set {
    name  = "additionalArguments[6]"
    value = "--certificatesresolvers.default.acme.storage=/data/acme.json"
  }
  set {
    name  = "additionalArguments[7]"
    value = "--serverstransport.insecureskipverify=true"
  }
  set {
    name = "additionalArguments[8]"
    value = "--metrics.prometheus=true"
  }
  set {
    name = "additionalArguments[9]"
    value = "--log.level=DEBUG"
  }

  # set environment variables to generate certificates for using Lets Encrypt.
  set {
    name = "env[0].name"
    value = "AWS_ACCESS_KEY"
  }
  set {
    name = "env[0].valueFrom.secretKeyRef.name"
    value = kubernetes_secret.route53-credentials.metadata[0].name
  }
  set {
    name = "env[0].valueFrom.secretKeyRef.key"
    value = "AWS_ACCESS_KEY"
  }
  set {
    name = "env[1].name"
    value = "AWS_SECRET_ACCESS_KEY"
  }
  set {
    name = "env[1].valueFrom.secretKeyRef.name"
    value = kubernetes_secret.route53-credentials.metadata[0].name
  }
  set {
    name = "env[1].valueFrom.secretKeyRef.key"
    value = "AWS_SECRET_ACCESS_KEY"
  }
  set {
    name = "env[2].name"
    value = "AWS_HOSTED_ZONE_ID"
  }
  set {
    name = "env[2].value"
    value = var.aws_hosted_zone_id
  }
}

#############################################
#
#
data "kubernetes_service" "traefik" {
  depends_on = [helm_release.traefik]
  metadata {
    name = "traefik"
    namespace = var.namespace.id
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
