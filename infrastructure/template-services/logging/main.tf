######################################################
# Install Grafana Loki  for centralizeed log indexing.
# See https://grafana.com/oss/loki/
#
######################################################
locals {
  labels = merge(var.labels, {
  })
  forwardauth_middleware_namespace = var.name_prefix
  forwardauth_middleware_name      = "forwardauth-authorize"
}

# deploy Loki-Stack with promtail
resource "helm_release" "loki-stack" {
  name       = "loki-stack"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  namespace  = var.name_prefix
  version    = "2.4.1"
}