######################################################
# Install ElasticCloud on K8s for centralized logging.
#
######################################################
locals {
  labels = merge(var.labels, {
  })
}
######################################################
# Install Elastic Cloud For Kubernetes Operator
#
######################################################
resource "helm_release" "elastic_operator" {
  name       = "elastic-operator"
  repository = "https://helm.elastic.co"
  chart      = "eck-operator"

  namespace = var.name_prefix

  set {
    name = "webhook.enabled"
    value = "false"
  }
  set {
    name = "managedNamespaces"
    value = "{services}"
  }
}


######################################################
# Deploy Elasticsearch
#
######################################################
resource "kubernetes_manifest" "elasticsearch" {
  provider   = kubernetes-alpha

  manifest = {
    "apiVersion" = "elasticsearch.k8s.elastic.co/v1"
    "kind"       = "Elasticsearch"
    "metadata" = {
      "namespace" = var.name_prefix
      "labels"    = local.labels
      "name"      = "elastic"
    }
    "spec" = {
      "version": "7.10.2"
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
    }
  }
}

######################################################
# Deploy Kibana
#
######################################################
resource "kubernetes_manifest" "kibana" {
  provider   = kubernetes-alpha

  manifest = {
    "apiVersion" = "kibana.k8s.elastic.co/v1"
    "kind"       = "Kibana"
    "metadata" = {
      "namespace" = var.name_prefix
      "labels"    = local.labels
      "name"      = "kibana"
    }
    "spec" = {
      "version": "7.10.2"
      "count" = 1
      "elasticsearchRef" = {
          "name" = "elastic"
          "namespace" = var.name_prefix
      }
    }
  }
}

######################################################
# Deploy APM-server
#
######################################################
resource "kubernetes_manifest" "apm_server" {
  provider   = kubernetes-alpha

  manifest = {
    "apiVersion" = "apm.k8s.elastic.co/v1beta1"
    "kind"       = "ApmServer"
    "metadata" = {
      "namespace" = var.name_prefix
      "labels"    = local.labels
      "name"      = "apm-server"
    }
    "spec" = {
      "version": "7.10.2"
      "count" = 1
      "elasticsearchRef" = {
        "name" = "elastic"
        "namespace" = var.name_prefix
      }
    }
  }
}


######################################################
# Deploy FileBeat to read logs
#
######################################################
resource "kubernetes_manifest" "filebeat" {
  provider   = kubernetes-alpha
  manifest = {
    "apiVersion" = "beat.k8s.elastic.co/v1beta1"
    "kind" = "Beat"
    "metadata" = {
      "name" = "beat"
      "namespace" = var.name_prefix
      "labels"    = local.labels
    }
    "spec" = {
      "config" = {
        "filebeat.inputs" = [
          {
            "paths" = [
              "/var/log/containers/*.log",
            ]
            "type" = "container"
          },
        ]
      }
      "daemonSet" = {
        "podTemplate" = {
          "spec" = {
            "containers" = [
              {
                "name" = "filebeat"
                "volumeMounts" = [
                  {
                    "mountPath" = "/var/log/containers"
                    "name" = "varlogcontainers"
                  },
                  {
                    "mountPath" = "/var/log/pods"
                    "name" = "varlogpods"
                  },
                  {
                    "mountPath" = "/var/lib/docker/containers"
                    "name" = "varlibdockercontainers"
                  },
                ]
              },
            ]
            "dnsPolicy" = "ClusterFirstWithHostNet"
            "hostNetwork" = true
            "securityContext" = {
              "runAsUser" = 0
            }
            "volumes" = [
              {
                "hostPath" = {
                  "path" = "/var/log/containers"
                }
                "name" = "varlogcontainers"
              },
              {
                "hostPath" = {
                  "path" = "/var/log/pods"
                }
                "name" = "varlogpods"
              },
              {
                "hostPath" = {
                  "path" = "/var/lib/docker/containers"
                }
                "name" = "varlibdockercontainers"
              },
            ]
          }
        }
      }
      "elasticsearchRef" = {
        "name" = "elastic"
        "namespace" = var.name_prefix
      }
      "type" = "filebeat"
      "version" = "7.10.2"
    }
  }
}