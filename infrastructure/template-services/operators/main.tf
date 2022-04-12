resource "kubernetes_namespace" "operators" {
  metadata {
    name = "operators"
  }
}

#####################################################################
# Deploy Minio Operator in Operators namespace.
####################################################################
#resource "helm_release" "minio_operator" {
#  name       = "minio-operator"
#  repository = "https://operator.min.io/"
#  chart      = "minio-operator"
#
#  namespace = kubernetes_namespace.operators.id
#
#  set {
#    name  = "helm.versions"
#    value = "v3"
#  }
#}

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