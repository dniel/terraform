######################################################
# Install ElasticCloud on K8s for centralized logging.
#
######################################################
locals {
  labels = merge(var.labels, {
  })
}

######################################################
# Deploy Elasticsearch
#
######################################################
//resource "kubernetes_manifest" "elasticsearch" {
//  provider   = kubernetes-alpha
//
//  manifest = {
//    "apiVersion" = "elasticsearch.k8s.elastic.co/v1"
//    "kind"       = "Elasticsearch"
//    "metadata" = {
//      "namespace" = var.name_prefix
//      "labels"    = local.labels
//      "name"      = "elastic"
//    }
//    "spec" = {
//      "version": "7.10.2"
//      "nodeSets" = [
//        {
//          "name" = "default"
//          "count" = 1
//          "config" = {
//            "node.store.allow_mmap" = false
//            "node.master" = true
//            "node.data" = true
//            "node.ingres" = true
//          }
//        }
//      ]
//    }
//  }
//}