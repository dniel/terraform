###################################################
# Template to configure a Unifi controller.
#
###################################################
locals {
  dns_name = "${var.name}.${var.domain_name}"
  labels = merge(var.labels, {
    "app" = var.name
  })
}

module "unifi" {
  source      = "github.com/dniel/terraform?ref=master/modules/helm-app"
  name_prefix = var.name_prefix
  domain_name = var.domain_name

  name          = var.name
  repository    = var.unifi_chart_repo
  chart         = var.unifi_chart_name
  chart_version = var.unifi_chart_version

  # Custom values for Chart.
  values = [
/*
    {
      name  = "image.tag"
      value = var.unifi_chart_image_tag
    },
*/
    {
      name  = "persistence.data.enabled"
      value = "true"
    },
    {
      name  = "persistence.data.accessMode"
      value = "ReadWriteOnce"
    },
    {
      name  = "persistence.data.size"
      value = "1Gi"
    },
    {
      name  = "mongodb.enabled"
      value = "false"
    },
    {
      name  = "mongodb.persistence.enabled"
      value = "false"
    },
    {
      name  = "mongodb.persistence.size"
      value = "2Gi"
    }
  ]
}

module "unifi_poller" {
  source      = "github.com/dniel/terraform?ref=master/modules/helm-app"
  name_prefix = var.name_prefix
  domain_name = var.domain_name

  name          = "unifi-poller"
  repository    = var.unifi_chart_repo
  chart         = "unifi-poller"
  chart_version = "10.2.0"

  values = [
    {
      name  = "config.unifi.defaults.url"
      value = "https://${var.name}:8443"
    },
    {
      name  = "prometheus.serviceMonitor.enabled"
      value = "true"
    },
    {
      name  = "prometheus.serviceMonitor.additionalLabels.release"
      value = "prometheus"
    },
    {
      name  = "prometheus.serviceMonitor.additionalLabels.monitor"
      value = "prometheus"
    }
  ]
}