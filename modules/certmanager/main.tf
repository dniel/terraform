locals {
  app_name = "cert-manager"
  labels = merge(var.labels, {
    "app" = local.app_name
  })
}

data "helm_repository" "jetstack" {
  name = "jetstack"
  url  = "https://charts.jetstack.io"
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
  repository = data.helm_repository.jetstack.id
  chart      = "cert-manager"
  namespace  = kubernetes_namespace.cert-manager.id
  version    = var.certmanager_helm_release_version
}