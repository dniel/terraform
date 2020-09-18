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

variable "spa_demo_helm_release_version" {
  type        = string
  description = "Version of Helm Chart to deploy"
}