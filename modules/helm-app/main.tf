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
  name       = var.name
  repository = var.repository
  chart      = var.chart
  version    = var.chart_version
  namespace  = var.name_prefix


  dynamic "set" {
    for_each = var.values
    content {
      name  = set.value.name
      value = set.value.value
    }
  }

  # TODO enable forwardauth conditionally
  set {
    name  = "ingressroute.middlewares[0].name"
    value = local.forwardauth_middleware_name
  }
  set {
    name  = "ingressroute.middlewares[0].namespace"
    value = local.forwardauth_middleware_namespace
  }
}

# TODO Add Alert rule

# TODO Add Monitor rule

# TODO Add uptimerobot

# TODO Add Auth0 config
