locals {
  app_name = "cert-manager"
  labels = merge(var.labels, {
    "app" = local.app_name
  })
}

resource "k8s_manifest" "certificate" {
  for_each = var.certificates

  content = templatefile("${path.module}/templates/certificate.tpl", {
    app_name    = local.app_name,
    domain_name = var.domain_name,
    name_prefix = var.name_prefix,
    name        = each.key
    secretName  = each.value.secretName,
    dnsName     = each.value.dnsName
  })
  namespace = each.value.namespace
}


resource "k8s_manifest" "cluster_issuer" {
  namespace = "cert-manager"
  content = templatefile("${path.module}/templates/clusterissuer.tpl", {
    app_name       = local.app_name,
    domain_name    = var.domain_name,
    name_prefix    = var.name_prefix,
    hosted_zone_id = var.hosted_zone_id
    accesskey      = var.aws_access_key
  })
}

resource "kubernetes_secret" "route53-credentials" {
  metadata {
    name      = "${var.name_prefix}-route53-creds"
    namespace = "cert-manager"
  }
  data = {
    AWS_SECRET_KEY = var.aws_secret_key
  }
  type = "Opaque"
}
