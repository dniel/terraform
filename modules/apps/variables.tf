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

variable "api_graphql_helm_release_version" {
  type        = string
  description = "Version of Helm Chart to deploy"
}

variable "api_posts_helm_release_version" {
  type        = string
  description = "Version of Helm Chart to deploy"
}

variable "website_helm_release_version" {
  type        = string
  description = "Version of Helm Chart to deploy"
}

variable "whoami_helm_release_version" {
  type        = string
  description = "Version of Helm Chart to deploy"
}
