variable "domain_name" {
  type        = string
  description = "Base domain used for environmant, ex. dniel.in"
}

variable "name_prefix" {
  type        = string
  description = "prefix to put on resources to be able to deploy multiple parallel versions of the env."
}

variable "labels" {
  type        = map(string)
  description = "Labels to add to resources created"
}

variable "namespace" {
  description = "Namespace to install apps in."
}

variable "load_balancer_public_ip" {
  default     = ""
  type        = string
  description = "Ip address of the external load balancer infront of Kubernetes Workers."
}

variable "load_balancer_alias_dns_name" {
  default     = ""
  type        = string
  description = "DNS Name of the external load balancer infront of Kubernetes Workers."
}

variable "load_balancer_alias_hosted_zone_id" {
  default     = ""
  type        = string
  description = "Hosted Zone of the external load balancer in-front of Kubernetes Workers."
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
