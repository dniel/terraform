locals {
  app_name = "cert-manager"
  labels = merge(var.labels, {
    "app" = local.app_name
  })
}

resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = local.app_name
    labels = merge(local.labels, {
      "certmanager.k8s.io/disable-validation" = "true"
    })
  }
}

resource "helm_release" "cert-manager" {
  name       = local.app_name
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = kubernetes_namespace.cert-manager.id
  version    = var.certmanager_helm_release_version

  set {
    name  = "extraArgs"
    value = "{--dns01-recursive-nameservers=8.8.8.8:53,1.1.1.1:53}"
  }
}