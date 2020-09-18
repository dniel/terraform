variable "domain_name" {
  type        = string
  description = "Base domain used for environmant, ex. dniel.in"
}

variable "name_prefix" {
  type        = string
  description = "prefix to put on resources to be able to deploy multiple parallel versions of the env."
}

variable "namespace" {
  description = "Namespace to install apps in."
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

