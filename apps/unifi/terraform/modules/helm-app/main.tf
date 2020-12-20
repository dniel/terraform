#############################################
#
#
#############################################
locals {
  forwardauth_middleware_namespace = var.name_prefix
  forwardauth_middleware_name      = "forwardauth-authorize"
}

# the hosted_zone to create whoami fqdn in.
data "aws_route53_zone" "selected_zone" {
  name = var.domain_name
}

# create the dns record in hosted zone.
resource "aws_route53_record" "dns_record" {
  zone_id = data.aws_route53_zone.selected_zone.zone_id
  name    = "${var.name}.${data.aws_route53_zone.selected_zone.name}"
  type    = "A"

  alias {
    name                   = "lb.${data.aws_route53_zone.selected_zone.name}"
    zone_id                = data.aws_route53_zone.selected_zone.zone_id
    evaluate_target_health = false
  }
}

# create helm release for application
resource "helm_release" "release" {
  name       = var.name
  repository = var.repository
  chart      = var.chart
  namespace  = var.name_prefix
  version    = var.chart_version

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
