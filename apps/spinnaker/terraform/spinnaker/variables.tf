variable "domain_name" {
  type        = string
  description = "Base domain used for environment, ex. nordlab.io"
}

variable "name_prefix" {
  type        = string
  description = "prefix to put on resources to be able to deploy multiple parallel versions of the env."
}

variable "labels" {
  type        = map(string)
  description = "Labels to add to resources created"
}