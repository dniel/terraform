resource "kubernetes_namespace" "operators" {
  metadata {
    name = "operators"
  }
}

#####################################################################
# Deploy Aromy Spinnaker Operator in Spinnaker namespace.
####################################################################
resource "helm_release" "helm_release_spinnaker_operator" {
  name       = "spinnaker"
  repository = "https://armory.jfrog.io/artifactory/charts/"
  chart      = "armory-spinnaker-operator"

  namespace = kubernetes_namespace.operators.id
}


######################################################
# Install kube-prometheus-stack.
#
######################################################
//resource "helm_release" "kube_prometheus_stack" {
//  name       = "prometheus"
//  repository = "https://prometheus-community.github.io/helm-charts"
//  chart      = "kube-prometheus-stack"
//
//  namespace = kubernetes_namespace.operators.id
//}


######################################################
# Install Elastic Cloud For Kubernetes Operator
#
######################################################
resource "helm_release" "elastic_operator" {
  name       = "elastic-operator"
  repository = "https://helm.elastic.co"
  chart      = "eck-operator"

  namespace = kubernetes_namespace.operators.id

  set {
    name = "webhook.enabled"
    value = "false"
  }
  set {
    name = "managedNamespaces"
    value = "{services}"
  }
}
