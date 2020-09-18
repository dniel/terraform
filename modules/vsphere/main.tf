locals {
  labels = merge(var.labels, {
    "app" = "vsphere"
  })
}

############################################################################
# TODO
# rename names, remove 2 from name when recreating vsphere cluster.
############################################################################
resource "kubernetes_manifest" "vsphere_cloudprovider_cluster_role" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "name" = "vsphere-cloud-provider-2"
      "labels" = local.labels
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "nodes",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
    ]
  }
}

############################################################################
# TODO
# rename names, remove 2 from name when recreating vsphere cluster.
############################################################################
resource "kubernetes_manifest" "vsphere_cloudprovider_cluster_role_binding" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "name" = "vsphere-cloud-provider-2"
      "namespace" = "kube-system"
      "labels" = local.labels
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "vsphere-cloud-provider-2"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "vsphere-cloud-provider"
        "namespace" = "kube-system"
      },
    ]
  }
}

resource "kubernetes_storage_class" "thin-disk" {
  depends_on = [
    kubernetes_manifest.vsphere_cloudprovider_cluster_role,
    kubernetes_manifest.vsphere_cloudprovider_cluster_role_binding,
  ]
  metadata {
    name = "thin-disk"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
    labels = local.labels
  }
  storage_provisioner = "kubernetes.io/vsphere-volume"
  reclaim_policy      = "Delete"
  parameters = {
    "diskformat" = "thin"
  }
  mount_options = []
}

