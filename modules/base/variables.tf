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

variable "traefik_helm_release_version" {
  type        = string
  description = "Version of Helm Chart to deploy"
}
variable "traefik_websecure_port" {
  type        = number
  description = "The exposed port for Traefik Ingress traefik. (HTTPS)"
}
variable "traefik_service_type" {
  default     = "NodePort"
  type        = string
  description = "Type of service, LoadBalancer or NodePort."
}
variable "labels" {
  type        = "map"
  description = "Labels to add to resources created"
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
  description = "Hosted Zone of the external load balancer infront of Kubernetes Workers."
}

variable "dns_names" {
  type        = list(string)
  description = "list of hostnames to create dns records for"
}

variable "certificates_aws_access_key" {
  type        = string
  description = "AWS Access Key to use for to modify hosted zone with DNS challenge response."
}

variable "certificates_aws_secret_key" {
  type        = string
  description = "AWS Secret Key to use for to modify hosted zone with DNS challenge response."
}

variable "primary_hosted_zone_id" {
  default     = ""
  type        = string
  description = "(Optional) Id of the primary hosted zone to add NS records for if its a nested hosted zone."
}

variable "traefik_default_tls_secretName" {
  default     = "traefik-default-tls"
  type        = string
  description = "(Optional) The name of the secret for the Traefik default certificate."
}
