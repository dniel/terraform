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

variable "namespace" {
  description = "Namespace to install apps in."
}

variable "hosted_zone_id" {
  type        = string
  description = "hosted_zone_id where certmananger should create DNS challenge response."
}

variable "aws_access_key" {
  type        = string
  description = "AWS Access Key to use for to modify hosted zone with DNS challenge response."
}

variable "aws_secret_key" {
  type        = string
  description = "AWS Secret Key to use for to modify hosted zone with DNS challenge response."
}

variable "certificates" {
  type = map(object({
    secretName = string
    dnsName    = string
    namespace  = string
  }))
  description = "Certificates to create"
}