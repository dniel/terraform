variable "domain_name" {
  type        = string
  description = "Base domain used for environment, ex. nordlab.io"
}

variable "name_prefix" {
  type        = string
  description = "prefix to put on resources to be able to deploy multiple parallel versions of the env."
}

variable "namespace" {
  description = "Namespace to install apps in."
}

variable "traefik_observe_namespaces" {
  type        = list(string)
  default     = []
  description = "Additional namepaces to observe with Traefik, default is only observe the name_prefix namespace."
}

variable "traefik_helm_release_version" {
  type        = string
  description = "Version of Helm Chart to deploy"
}

variable "traefik_websecure_port" {
  default     = 32443
  type        = number
  description = "The exposed port for Traefik Ingress traefik. (HTTPS)"
}

variable "traefik_service_type" {
  default     = "NodePort"
  type        = string
  description = "Type of service, LoadBalancer or NodePort."
}

variable "labels" {
  type        = map(string)
  description = "Labels to add to resources created"
}

variable "traefik_pilot_token" {
  default     = ""
  type        = string
  description = "Token to use to connect to Traefik Pilot"
}

variable "aws_access_key" {
  type = string
}
variable "aws_secret_access_key" {
  type = string
}
variable "aws_hosted_zone_id" {
  type = string
}
