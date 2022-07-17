resource "kubernetes_config_map" "unifi_poller_client_insights" {
  metadata {
    name = "dashboard-unifi-poller-client-insights"
    namespace = var.name_prefix
    labels = {
      grafana_dashboard: "1"
    }
  }

  data = {
    "unifi-poller-client-insights.json" = file("${path.module}/dashboards/up-clients.json")
  }
}

resource "kubernetes_config_map" "unifi_poller_sites_insights" {
  metadata {
    name = "dashboard-unifi-poller-sites-insights"
    namespace = var.name_prefix
    labels = {
      grafana_dashboard: "1"
    }
  }

  data = {
    "unifi-poller-sites-insights.json" = file("${path.module}/dashboards/up-sites.json")
  }
}

resource "kubernetes_config_map" "unifi_poller_uap_insights" {
  metadata {
    name = "dashboard-unifi-poller-uap-insights"
    namespace = var.name_prefix
    labels = {
      grafana_dashboard: "1"
    }
  }

  data = {
    "unifi-poller-uap-insights.json" = file("${path.module}/dashboards/up-uap.json")
  }
}

resource "kubernetes_config_map" "unifi_poller_usg_insights" {
  metadata {
    name = "dashboard-unifi-poller-usg-insights"
    namespace = var.name_prefix
    labels = {
      grafana_dashboard: "1"
    }
  }

  data = {
    "unifi-poller-usg-insights.json" = file("${path.module}/dashboards/up-usg.json")
  }
}

resource "kubernetes_config_map" "unifi_poller_usw_insights" {
  metadata {
    name = "dashboard-unifi-poller-usw-insights"
    namespace = var.name_prefix
    labels = {
      grafana_dashboard: "1"
    }
  }

  data = {
    "unifi-poller-usw-insights.json" = file("${path.module}/dashboards/up-usw.json")
  }
}

resource "kubernetes_config_map" "vmware_cluster" {
  metadata {
    name = "dashboard-vmware-cluster"
    namespace = var.name_prefix
    labels = {
      grafana_dashboard: "1"
    }
  }

  data = {
    "vmware-cluster.json" = file("${path.module}/dashboards/vmware-cluster.json")
  }
}

resource "kubernetes_config_map" "vmware_esxi" {
  metadata {
    name = "dashboard-vmware-esxi"
    namespace = var.name_prefix
    labels = {
      grafana_dashboard: "1"
    }
  }

  data = {
    "vmware-esxi.json" = file("${path.module}/dashboards/vmware-esxi.json")
  }
}

resource "kubernetes_config_map" "vmware_virtual_machines" {
  metadata {
    name = "dashboard-vmware-vm"
    namespace = var.name_prefix
    labels = {
      grafana_dashboard: "1"
    }
  }

  data = {
    "vmware-vm.json" = file("${path.module}/dashboards/vmware-vm.json")
  }
}
