variable "domain_name" {
  type        = string
  description = "Base domain used for environmant, ex. dniel.in"
}

variable "name_prefix" {
  type        = string
  description = "prefix to put on resources to be able to deploy multiple parallel versions of the env."
}

variable "labels" {
  type        = "map"
  description = "Labels to add to resources created"
}

variable "http_monitors" {
  default = {}
  type = map(object({
    address = string
  }))
  description = "Http Monitors to create"
}

variable "port_monitors" {
  default = {}
  type = map(object({
    address = string
    port = number
  }))
  description = "TCP Port Monitors to create"
}