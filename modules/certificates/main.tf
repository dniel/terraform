locals {
  app_name = "cert-manager"
  labels = merge(var.labels, {
    "app" = local.app_name
  })
}

resource "kubernetes_manifest" "certificate" {
  for_each = var.certificates
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "cert-manager.io/v1alpha3"
    "kind" = "Certificate"
    "metadata" = {
      "labels" = local.labels
      "name" = each.key
      "namespace" = each.value.namespace
    }
    "spec" = {
      "commonName" = each.value.dnsName
      "dnsNames" = [
        each.value.dnsName
      ]
      "issuerRef" = {
        "kind" = "ClusterIssuer"
        "name" = "letsencrypt-${var.name_prefix}-issuer"
      }
      "renewBefore" = "360h"
      "secretName" = each.value.secretName
    }
  }
}

resource "kubernetes_manifest" "cluster_issuer" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "cert-manager.io/v1alpha3"
    "kind" = "ClusterIssuer"
    "metadata" = {
      "name" = "letsencrypt-${var.name_prefix}-issuer"
      "namespace" = "cert-manager"
    }
    "spec" = {
      "acme" = {
        "email" = "daniel@engfeldt.net"
        "privateKeySecretRef" = {
          "name" = "letsencrypt-dns01-prod"
        }
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        "solvers" = [
          {
            "dns01" = {
              "route53" = {
                "accessKeyID" = var.aws_access_key
                "hostedZoneID" = var.hosted_zone_id
                "region" = "eu-central-1"
                "role" = ""
                "secretAccessKeySecretRef" = {
                  "key" = "AWS_SECRET_KEY"
                  "name" = "${var.name_prefix}-route53-creds"
                }
              }
            }
            "selector" = {
              "dnsZones" = [var.domain_name]
            }
          },
        ]
      }
    }
  }
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
