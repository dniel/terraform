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
    "kind"       = "ClusterRole"
    "metadata" = {
      "name"   = "vsphere-cloud-provider-2"
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
    "kind"       = "ClusterRoleBinding"
    "metadata" = {
      "name"      = "vsphere-cloud-provider-2"
      "labels"    = local.labels
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind"     = "ClusterRole"
      "name"     = "vsphere-cloud-provider-2"
    }
    "subjects" = [
      {
        "kind"      = "ServiceAccount"
        "name"      = "vsphere-cloud-provider"
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
    "datastore"  = "syno2"
  }
  mount_options = []
}

//
//data "vsphere_datacenter" "dc" {
//  name = "home-dc"
//}
//
//data "vsphere_datastore" "datastore" {
//  name          = "syno2"
//  datacenter_id = data.vsphere_datacenter.dc.id
//}
//
//data "vsphere_resource_pool" "pool" {
//  name          = "Homelab/Resources"
//  datacenter_id = data.vsphere_datacenter.dc.id
//}
//
//data "vsphere_network" "network" {
//  name          = "DMZ Network"
//  datacenter_id = data.vsphere_datacenter.dc.id
//}
//
//data "vsphere_content_library" "library" {
//  name = "newisos"
//}
//
//data "vsphere_content_library_item" "item" {
//  name       = "photon-hw13_uefi-3.0-a383732"
//  library_id = data.vsphere_content_library.library.id
//  type = "ovf"
//}
//
//data "vsphere_host" "host" {
//  name          = "10.0.50.18"
//  datacenter_id = data.vsphere_datacenter.dc.id
//}
//
//resource "vsphere_virtual_machine" "vm" {
//  name             = "terraform-test"
//  resource_pool_id = data.vsphere_resource_pool.pool.id
//  datastore_id     = data.vsphere_datastore.datastore.id
//
//  firmware = "efi"
//  num_cpus = 2
//  memory   = 1024
//
//  network_interface {
//    network_id = data.vsphere_network.network.id
//  }
//
//  disk {
//    label = "disk0"
//    size = 20
//    thin_provisioned = true
//  }
//
//  clone {
//    template_uuid = data.vsphere_content_library_item.item.id
//  }
//}