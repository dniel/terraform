locals {
  dns_name = "unifi.${var.domain_name}"
  labels = merge(var.labels, {
    "app" = "unifi"
  })
}

module "unifi" {
  source            = "../helm-app"
  name_prefix       = var.name_prefix
  domain_name       = var.domain_name

  name       = "unifi"
  repository = "https://k8s-at-home.com/charts"
  chart      = "unifi"
  chart_version    = "1.0.0"

  # Custom values for Chart.
  values = [
    {
      name = "image.tag"
      value = var.unifi_image_tag
    }
  ]
}

resource "helm_release" "helm_release_unifi_poller" {
  name       = "unifi-poller"
  repository = "https://k8s-at-home.com/charts"
  chart      = "unifi-poller"
  namespace  = var.name_prefix

  set{
    name = "config.unifi.defaults.url"
    value = "https://unifi-gui:8443"
  }
  set{
    name = "prometheus.serviceMonitor.enabled"
    value = "true"
  }
  set {
    name  = "prometheus.serviceMonitor.additionalLabels.release"
    value = "prometheus"
  }
  set {
    name  = "prometheus.serviceMonitor.additionalLabels.monitor"
    value = "prometheus"
  }
}

resource "kubernetes_ingress" "unifi_gui_ingress" {
  metadata {
    name      = "unifi-gui"
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
            service_name = "unifi-gui"
            service_port = "https-gui"
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress" "unifi_inform_ingress" {
  metadata {
    name      = "unifi-inform"
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
            service_name = "unifi-controller"
            service_port = "controller"
          }
        }
      }
    }
  }
}
