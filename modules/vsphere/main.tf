locals {
  labels = merge(var.labels, {
    "app" = "vsphere"
  })
}

#############################################################
# TODO enable next time recreating the cluster
#
############################################################
#resource "k8s_manifest" "vsphere-rbac-manifest" {
#  content = templatefile("${path.module}/templates/rbac.yaml", local.labels)
#}

resource "kubernetes_storage_class" "thin-disk" {
#  depends_on = [k8s_manifest.vsphere-rbac-manifest]
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

