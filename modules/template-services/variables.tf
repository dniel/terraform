variable "base_domain_name" {}
variable "name_prefix" {}
variable "hosted_zone_id" {}

variable "feature_monitoring" {
  type = bool
  default = false
  description = "Enable/Disable installation of Prometheus and Grafana"
}

variable "feature_spinnaker" {
  type = bool
  default = false
  description = "Enable/Disable installation of Spinnaker"
}

variable "feature_vsphere" {
  type = bool
  default = false
  description = "Enable/Disable vsphere specific components."
}
