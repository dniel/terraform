resource "kubernetes_namespace" "operators" {
  metadata {
    name = "operators"
  }
}

######################################################
# Install Helm operator from Flux
#
######################################################
resource "helm_release" "helm_operator" {
  name       = "helm-operator"
  repository = "https://charts.fluxcd.io"
  chart      = "helm-operator"

  namespace = kubernetes_namespace.operators.id

  set {
    name = "helm.versions"
    value = "v3"
  }
}

#####################################################################
# Deploy Aromy Spinnaker Operator in Spinnaker namespace.
####################################################################
resource "kubernetes_manifest" "spinnaker_operator" {
  depends_on = [helm_release.helm_operator]
  provider   = kubernetes-alpha

  manifest = {
    "apiVersion" = "helm.fluxcd.io/v1"
    "kind"       = "HelmRelease"
    "metadata" = {
      "namespace" = kubernetes_namespace.operators.id
      "name"      = "spinnaker"
    }
    "spec" = {
      "chart" = {
        "repository" = "https://armory.jfrog.io/artifactory/charts/"
        "name" = "armory-spinnaker-operator"
        "version" = "1.2.3"
      }
    }
  }
}

######################################################
# Install Elastic Cloud For Kubernetes Operator
#
######################################################
resource "kubernetes_manifest" "elastic_operator" {
  depends_on = [helm_release.helm_operator]
  provider   = kubernetes-alpha

  manifest = {
    "apiVersion" = "helm.fluxcd.io/v1"
    "kind"       = "HelmRelease"
    "metadata" = {
      "namespace" = kubernetes_namespace.operators.id
      "name"      = "eck-operator"
    }
    "spec" = {
      "chart" = {
        "repository" = "https://helm.elastic.co"
        "name" = "eck-operator"
        "version" = "1.3.1"
      }
    }
  }
}

######################################################
# Install kube-prometheus-stack.
#
######################################################
resource "kubernetes_manifest" "kube_prometheus_stack" {
  depends_on = [helm_release.helm_operator]
  provider   = kubernetes-alpha

  manifest = {
    "apiVersion" = "helm.fluxcd.io/v1"
    "kind"       = "HelmRelease"
    "metadata" = {
      "namespace" = kubernetes_namespace.operators.id
      "name"      = "kube-prometheus-stack"
    }
    "spec" = {
      "chart" = {
        "repository" = "https://prometheus-community.github.io/helm-charts"
        "name" = "kube-prometheus-stack"
        "version" = "13.4.1"
      }
    }
  }
}