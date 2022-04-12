#############################################
#
#
#############################################
locals {
  forwardauth_middleware_namespace = var.name_prefix
  forwardauth_middleware_name      = "forwardauth-authorize"
}

# create helm release for application
resource "helm_release" "release" {
  namespace     = var.name_prefix
  repository    = "https://dniel.github.io/charts"
  name          = "whoami"
  chart         = "whoami"
  version       = "0.8.1"

  set {
    name  = "ingressroute.enabled"
    value = "true"
  }
  set {
    name  = "ingressroute.annotations.kubernetes\\.io/ingress\\.class"
    value = "traefik-${var.name_prefix}"
  }
  set {
    name  = "ingressroute.hostname"
    value = "whoami.${var.domain_name}"
  }
  set {
    name  = "ingressroute.middlewares[0].name"
    value = local.forwardauth_middleware_name
  }
  set {
    name  = "ingressroute.middlewares[0].namespace"
    value = local.forwardauth_middleware_namespace
  }
}