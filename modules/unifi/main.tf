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
    {
      name  = "image.tag"
      value = var.unifi_chart_image_tag
    },
    {
      name  = "persistence.data.enabled"
      value = "true"
    },
    {
      name  = "persistence.data.accessMode"
      value = "ReadWriteOnce"
    },
    {
      name  = "persistence.data.retain"
      value = "true"
    },
    {
      name  = "persistence.data.size"
      value = "128Mi"
    },
    {
      name  = "mongodb.enabled"
      value = "true"
    },
    {
      name  = "mongodb.persistence.enabled"
      value = "true"
    },
    {
      name  = "mongodb.persistence.size"
      value = "512Mi"
    },
    {
      name  = "mongodb.persistence.retain"
      value = "true"
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
      name  = "env.TZ"
      value = "UTC"
    },
    {
      name  = "env.UP_UNIFI_DEFAULT_URL"
      value = "https://${var.name}:8443"
    },
    {
      name  = "env.UP_UNIFI_DEFAULT_USER"
      value = "unifipoller"
    },
    {
      name  = "env.UP_UNIFI_DEFAULT_PASS"
      value = "unifipoller"
    },
    {
      name  = "env.UP_INFLUXDB_DISABLE"
      value = "true"
    },
    {
      name  = "env.UP_PROMETHEUS_DISABLE"
      value = "false"
    },
    {
      name  = "metrics.enabled"
      value = "true"
    },
    {
      name  = "metrics.serviceMonitor.labels.release"
      value = "kube-prometheus-stack"
    },
  ]
}