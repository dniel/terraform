variable "domain_name" {}
variable "name_prefix" {}
variable "hosted_zone_id" {}

variable "feature_spinnaker" {
  type        = bool
  default     = false
  description = "Enable/Disable installation of Spinnaker"
}

variable "feature_vsphere" {
  type        = bool
  default     = false
  description = "Enable/Disable vsphere specific components."
}

variable "unifi_helm_release_version" {
  type        = string
  description = "Version of Helm Chart to deploy"
}

variable "unifi_image_tag" {
  type        = string
  description = "Thre Docker container tag to deploy."
}

variable "kube_prometheus_stack_chart_version" {
  type        = string
  description = "Version of Helm Chart to deploy"
  default     = "14.5.0"
}
