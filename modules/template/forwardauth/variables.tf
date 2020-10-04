variable "domain_name" {
  type        = string
  description = "Base domain used for environment, ex. dniel.in"
}

variable "name_prefix" {
  type        = string
  description = "prefix to put on resources to be able to deploy multiple parallel versions of the env."
}

variable "namespace" {
  description = "Namespace to install apps in."
}

variable "forwardauth_tenant" {
  type        = string
  description = "Auth0 tenant domain name."
}

variable "forwardauth_helm_release_version" {
  type        = string
  description = "Version of Helm Chart to deploy"
}

variable "labels" {
  type        = map(string)
  description = "Labels to add to resources created"
}
