locals {
  vcenter_hostname = "vcenter.dniel.in"
}

resource "kubernetes_manifest" "externalsecret_vcenter" {
  manifest = {
    "apiVersion" = "kubernetes-client.io/v1"
    "kind" = "ExternalSecret"
    "metadata" = {
      "name" = "vcenter"
      "namespace" = var.name_prefix
    }
    "spec" = {
      "backendType" = "secretsManager"
      "data" = [
        {
          "key" = "vcenter/password"
          "name" = "password"
        },
        {
          "key" = "vcenter/username"
          "name" = "username"
        },
      ]
    }
  }
}

resource "helm_release" "prometheus_vmware_exporter" {
  depends_on = [kubernetes_manifest.externalsecret_vcenter]
  name = "vmware-exporter"
  repository = "https://dniel.github.io/charts"
  chart = "vmware-exporter"
  namespace = var.name_prefix
  version = "0.0.1"
  set {
    name  = "env.VSPHERE_USER.valueFrom.secretKeyRef.name"
    value = "vcenter"
  }
  set {
    name  = "env.VSPHERE_USER.valueFrom.secretKeyRef.key"
    value = "username"
  }
  set {
    name  = "env.VSPHERE_PASSWORD.valueFrom.secretKeyRef.name"
    value = "vcenter"
  }
  set {
    name  = "env.VSPHERE_PASSWORD.valueFrom.secretKeyRef.key"
    value = "password"
  }
  set {
    name  = "env.VSPHERE_HOST"
    value = local.vcenter_hostname
  }
  set {
    name  = "env.VSPHERE_IGNORE_SSL"
    value = "true"
  }
}