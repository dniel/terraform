locals {
  app_name = "forwardauth"
  labels = merge(var.labels, {
    "app" = local.app_name
  })
}

resource "auth0_client" "traefik_client" {
  name        = title("Traefik ${var.name_prefix}")
  description = title("Traefik for ${var.name_prefix}")
  app_type    = "regular_web"
  callbacks = [
    "https://auth.${var.domain_name}/signin",
    "https://*.${var.domain_name}/auth/signin"
  ]
  allowed_logout_urls = [
    "https://spademo.${var.domain_name}/logout",
  ]
  oidc_conformant = true

  jwt_configuration {
    alg = "RS256"
  }
}

resource "auth0_resource_server" "env_meta_server" {
  name             = title("Traefik ${var.name_prefix}")
  identifier       = "https://${var.domain_name}"
  enforce_policies = true
  token_dialect    = "access_token_authz"
}

resource "helm_release" "forwardauth" {
  name       = local.app_name
  repository = "https://dniel.github.com/charts"
  chart      = local.app_name
  namespace  = var.namespace.id
  version    = var.forwardauth_helm_release_version
  set {
    name  = "ingressroute.annotations.kubernetes\\.io/ingress\\.class"
    value = "traefik-${var.name_prefix}"
  }
  set {
    name  = "default.clientid"
    value = auth0_client.traefik_client.client_id
  }
  set {
    name  = "default.clientsecret"
    value = auth0_client.traefik_client.client_secret
  }
  set {
    name  = "default.audience"
    value = auth0_resource_server.env_meta_server.identifier
  }
  set {
    name  = "default.tokenCookieDomain"
    value = var.domain_name
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
    value = "false"
  }
  set {
    name  = "mode.host"
    value = "true"
  }
  set {
    name  = "mode.path"
    value = "true"
  }

  values = [
    templatefile("${path.module}/forwardauth-values.tpl", {
      app_name    = local.app_name,
      domain_name = var.domain_name,
      name_prefix = var.name_prefix,
      tenant      = var.forwardauth_tenant
    })
  ]
}


resource "kubernetes_manifest" "middleware_forwardauth" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" : "traefik.containo.us/v1alpha1"
    "kind" : "Middleware"
    "metadata" : {
      "labels" : local.labels
      "namespace" : var.namespace.id
      "name" : "forwardauth-authorize"
    }
    "spec" : {
      "forwardAuth" : {
        "address" : "http://forwardauth/authorize"
        "trustForwardHeader" : true
        "authResponseHeaders" : [
          #          "authorization",
          "x-forwardauth-nickname",
          "x-forwardauth-family-name",
          "x-forwardauth-given-name",
          "x-forwardauth-name",
          "x-forwardauth-sub",
          "x-forwardauth-email"
        ]
      }
    }
  }
}