resource "helm_release" "prometheus_snmp_exporter" {
  name = "snmp-exporter"
  repository = "https://dniel.github.io/charts"
  chart = "snmp-exporter"
  namespace = var.name_prefix
  version = "0.0.3"
}

resource "kubernetes_manifest" "servicemonitor_services_snmp_exporter" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind" = "ServiceMonitor"
    "metadata" = {
      "labels" = {
        "release" = "kube-prometheus-stack"
      }
      "name" = "snmp-exporter"
      "namespace" = "services"
    }
    "spec" = {
      "endpoints" = [
        {
          "honorLabels" = true
          "interval" = "60s"
          "params" = {
            "module" = [
              "apcups",
            ]
            "target" = [
              "10.0.1.41",
            ]
          }
          "path" = "/snmp"
          "port" = "http"
          "relabelings" = [
            {
              "sourceLabels" = [
                "__param_target",
              ]
              "targetLabel" = "host"
            },
          ]
          "targetPort" = 9116
        },
        {
          "honorLabels" = true
          "interval" = "60s"
          "params" = {
            "module" = [
              "apcups",
            ]
            "target" = [
              "pdu.dniel.in",
            ]
          }
          "path" = "/snmp"
          "port" = "http"
          "relabelings" = [
            {
              "sourceLabels" = [
                "__param_target",
              ]
              "targetLabel" = "host"
            },
          ]
          "targetPort" = 9116
        },
        {
          "honorLabels" = true
          "interval" = "60s"
          "params" = {
            "module" = [
              "synology",
            ]
            "target" = [
              "nas.dniel.in",
            ]
          }
          "path" = "/snmp"
          "port" = "http"
          "relabelings" = [
            {
              "sourceLabels" = [
                "__param_target",
              ]
              "targetLabel" = "host"
            },
          ]
          "targetPort" = 9116
        },
      ]
      "selector" = {
        "matchLabels" = {
          "app.kubernetes.io/instance" = "snmp-exporter"
          "app.kubernetes.io/name" = "snmp-exporter"
        }
      }
    }
  }
}