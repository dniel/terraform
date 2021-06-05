variable "name" {
  type        = string
  description = "The application name, default is unifi"
  default     = "unifi"
}


variable "domain_name" {
  type        = string
  description = "Base domain used for environment, ex. nordlab.io"
}

variable "name_prefix" {
  type        = string
  description = "prefix to put on resources to be able to deploy multiple parallel versions of the env."
}

variable "unifi_chart_repo" {
  type        = string
  description = "(Optional) URL to the helm repository to install chart from, default 'https://k8s-at-home.com/charts'"
  default     = "https://k8s-at-home.com/charts"
}

variable "unifi_chart_name" {
  type        = string
  description = "(Optional) Name of the chart to install, default unifi"
  default     = "unifi"
}

variable "unifi_chart_version" {
  type        = string
  description = "Version of Helm Chart to deploy"
}

variable "unifi_chart_image_tag" {
  type        = string
  description = "Docker container tag to deploy with chart."
}

variable "labels" {
  default     = {}
  type        = map(string)
  description = "Labels to add to resources created"
}

variable "install_unifi_poller" {
  type        = bool
  description = "Deploy unifi poller as well. Default is True."
  default     = true
}
