variable "domain_name" {
  type        = string
  description = "Base domain used for environment, ex. dniel.in"
}

variable "name_prefix" {
  type        = string
  description = "prefix to put on resources to be able to deploy multiple parallel versions of the env."
}

variable "unifi_helm_release_version" {
  type        = string
  description = "Version of Helm Chart to deploy"
}

variable "unifi_image_tag" {
  type = string
  description = "Thre Docker container tag to deploy."
}

variable "labels" {
  type        = map(string)
  description = "Labels to add to resources created"
}

variable "hosted_zone_id" {
  type        = string
  description = "Id of the hosted zone to add NS records."
}