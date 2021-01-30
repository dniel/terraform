######################################################
# Install ElasticCloud on K8s for centralized logging.
#
######################################################
locals {
  labels = merge(var.labels, {
  })
}

# this is a workaround
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
