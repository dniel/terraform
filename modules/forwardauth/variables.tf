variable "domain_name" {
  type        = string
  description = "Base domain used for environmant, ex. dniel.in"
}

variable "name_prefix" {
  type        = string
  description = "prefix to put on resources to be able to deploy multiple parallel versions of the env."
}

variable "forwardauth_clientid" {
  type        = string
  description = "Client id used by forwardauth to authenticate and authorize requests."
}

variable "forwardauth_clientsecret" {
  type        = string
  description = "Client Secret used by forwardauth to authenticate and authorize requests."
}

variable "forwardauth_audience" {
  type        = string
  description = "Audience used by forwardauth to authenticate and authorize requests."
}

variable "forwardauth_token_cookie_domain" {
  type        = string
  description = "Cookie domain used by forwardauth to authenticate and authorize requests."
}

variable "forwardauth_helm_release_version" {
  type        = string
  description = "Version of Helm Chart to deploy"
}

variable "labels" {
  type        = "map"
  description = "Labels to add to resources created"
}
