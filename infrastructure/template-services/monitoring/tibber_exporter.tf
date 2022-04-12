resource "kubernetes_manifest" "externalsecret_tibber" {
  manifest = {
    "apiVersion" = "kubernetes-client.io/v1"
    "kind" = "ExternalSecret"
    "metadata" = {
      "name" = "tibber"
      "namespace" = var.name_prefix
    }
    "spec" = {
      "backendType" = "secretsManager"
      "data" = [
        {
          "key" = "tibber/token"
          "name" = "token"
        },
      ]
    }
  }
}

resource "helm_release" "prometheus_tibber_exporter" {
  depends_on = [kubernetes_manifest.externalsecret_tibber]
  name = "tibber-exporter"
  repository = "https://dniel.github.io/charts"
  chart = "tibber-exporter"
  namespace = var.name_prefix
  version = "0.0.5"
  set {
    name  = "env.TIBBER_TOKEN.valueFrom.secretKeyRef.name"
    value = "tibber"
  }
  set {
    name  = "env.TIBBER_TOKEN.valueFrom.secretKeyRef.key"
    value = "token"
  }
}