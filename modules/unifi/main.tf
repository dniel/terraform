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
    }
  ]
}

module "unifi_poller" {
  count       = var.install_unifi_poller ? 1 : 0
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

resource "kubernetes_ingress" "unifi_gui_ingress" {
  metadata {
    name      = "${var.name}-gui"
    namespace = var.name_prefix
    annotations = {
      "kubernetes.io/ingress.class"                           = "traefik-${var.name_prefix}"
      "traefik.ingress.kubernetes.io/router.entrypoints"      = "websecure"
      "traefik.ingress.kubernetes.io/router.tls.certresolver" = "default"
      "ingress.kubernetes.io/protocol"                        = "https"
    }
    labels = local.labels
  }

  spec {
    rule {
      host = local.dns_name
      http {
        path {
          backend {
            service_name = "${var.name}-gui"
            service_port = "https-gui"
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress" "unifi_inform_ingress" {
  metadata {
    name      = "${var.name}-inform"
    namespace = var.name_prefix
    annotations = {
      "kubernetes.io/ingress.class"                      = "traefik-${var.name_prefix}"
      "traefik.ingress.kubernetes.io/router.entrypoints" = "web"
    }
    labels = local.labels
  }

  spec {
    rule {
      host = local.dns_name
      http {
        path {
          path = "/inform"
          backend {
            service_name = "${var.name}-controller"
            service_port = "controller"
          }
        }
      }
    }
  }
}
