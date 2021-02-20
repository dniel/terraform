######################################################
# Install ElasticCloud on K8s for centralized logging.
# https://github.com/elastic/cloud-on-k8s
#
# This module is a little bit special beacuse its the
# only module that use banzaicloud/k8s to apply
# manifests instead of kubernetes-alpha from hashicorp.
#
# The reason for that is the alpha provider didnt work
# well with the provider to create new resources and
# using the terraform plan with dry-run.
######################################################
locals {
  labels = merge(var.labels, {
  })
  forwardauth_middleware_namespace = var.name_prefix
  forwardauth_middleware_name      = "forwardauth-authorize"
}

# this is a workaround for this module to use the correct provider
# https://github.com/banzaicloud/terraform-provider-k8s/issues/63
terraform {
  required_version = ">= 0.13"

  required_providers {
    k8s = {
      source  = "banzaicloud/k8s"
      version = ">=0.9.0"
    }
  }
}

######################################################
# Deploy Elasticsearch using CRD from operator.
#
######################################################
resource "k8s_manifest" "elastic" {
  content = file("${path.module}/manifests/elastic.yml")
}

######################################################
# Deploy Kibana using CRD from operator.
#
######################################################
resource "k8s_manifest" "kibana" {
  content = file("${path.module}/manifests/kibana.yml")
}

######################################################
# Deploy Filebeat using CRD from operator.
#
######################################################
resource "k8s_manifest" "filebeat" {
  content = file("${path.module}/manifests/filebeat.yml")
}

######################################################
# Expose Kibana in Traefik load balancer using a dns alias.
#
######################################################
module "kibana_alias_record" {
  source = "../../dns-cname-record"

  alias_name     = "kibana"
  alias_target   = "lb.${var.domain_name}"
  domain_name    = var.domain_name
  hosted_zone_id = var.hosted_zone_id
  labels         = local.labels
  name_prefix    = var.name_prefix
}

resource "kubernetes_manifest" "ingressroute_kibana" {
  provider = kubernetes-alpha

  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "annotations" = {
        "kubernetes.io/ingress.class" = "traefik-${var.name_prefix}"
      },
      "namespace" = var.name_prefix
      "labels"    = local.labels
      "name"      = "kibana"
    }
    "spec" = {
      "entryPoints" = [
        "websecure",
      ]
      "routes" = [
        {
          "kind"  = "Rule"
          "match" = "Host(`kibana.${var.domain_name}`)"
          "middlewares" = [
            {
              "name"      = local.forwardauth_middleware_name
              "namespace" = local.forwardauth_middleware_namespace
            },
          ]
          "services" = [
            {
              "name" = "services-kb-http"
              "port" = 5601
            },
          ]
        },
      ]
      "tls" = {
        "certResolver" = "default"
      }
    }
  }
}
