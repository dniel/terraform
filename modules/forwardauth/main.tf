locals {
  app_name = "forwardauth"
  labels = merge(var.labels, {
    "app" = local.app_name
  })
}

data "helm_repository" "dniel" {
  name = "dniel"
  url  = "https://dniel.github.com/charts"
}

resource "kubernetes_namespace" "forwardauth" {
  metadata {
    name   = "${var.name_prefix}-${local.app_name}"
    labels = local.labels
  }
}

resource "helm_release" "forwardauth" {
  name       = local.app_name
  repository = data.helm_repository.dniel.id
  chart      = local.app_name
  namespace  = kubernetes_namespace.forwardauth.id
  version    = var.forwardauth_helm_release_version
  set {
    name  = "ingressroute.annotations.kubernetes\\.io/ingress\\.class"
    value = "traefik-${var.name_prefix}"
  }
  set {
    name  = "default.clientid"
    value = var.forwardauth_clientid
  }
  set {
    name  = "default.clientsecret"
    value = var.forwardauth_clientsecret
  }
  set {
    name  = "default.audience"
    value = var.forwardauth_audience
  }
  set {
    name  = "default.tokenCookieDomain"
    value = var.forwardauth_token_cookie_domain
  }
  set {
    name  = "ingressroute.enabled"
    value = "true"
  }
  set {
    name  = "ingressroute.hostname"
    value = "auth.${var.domain_name}"
  }
  set {
    name  = "middleware.enabled"
    value = "true"
  }

  values = [
    templatefile("${path.module}/forwardauth-values.tpl", {
      app_name    = local.app_name,
      domain_name = var.domain_name,
      name_prefix = var.name_prefix
    })
  ]
}
