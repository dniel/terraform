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

variable "load_balancer_public_ip" {
  type        = string
  description = "Ip address to access deployed applications."
}

variable "dns_names" {
  type        = list(string)
  description = "list of hostnames to create dns records for"
}

variable "primary_hosted_zone_id" {
  default     = ""
  type        = string
  description = "(Optional) Id of the primary hosted zone to add NS records for if its a nested hosted zone."
}
