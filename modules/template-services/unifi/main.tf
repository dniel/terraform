locals {
  dns_name = "unifi.${var.domain_name}"
  labels = merge(var.labels, {
    "app" = "unifi"
  })
}

resource "helm_release" "helm_release_unifi" {
  name       = "unifi"
  repository = "https://k8s-at-home.com/charts"
  chart      = "unifi"
  version    = var.unifi_helm_release_version
  namespace  = var.name_prefix

  set{
    name = "image.tag"
    value = var.unifi_image_tag
  }
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

# Create Alias A records for Unifi
resource "aws_route53_record" "unifi_alias_record" {
  zone_id = var.hosted_zone_id
  name    = "unifi"
  type    = "A"

  alias {
    name                   = "lb.${var.domain_name}"
    zone_id                = var.hosted_zone_id
    evaluate_target_health = false
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
