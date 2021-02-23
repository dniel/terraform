# basic config
variable "domain_name" {}
variable "name_prefix" {}

variable "load_balancer_public_ip" {}
variable "load_balancer_alias_hosted_zone_id" {}
variable "load_balancer_alias_dns_name" {}
variable "primary_hosted_zone_id" {}

# traefik config
variable "traefik_pilot_token" {}
variable "traefik_aws_access_key" {}
variable "traefik_aws_secret_key" {}
variable "traefik_websecure_port" {}
variable "traefik_service_type" {}
variable "traefik_default_tls_secretName" {}
variable "traefik_helm_chart_version" {}

variable "traefik_observe_namespaces" {
  type        = list(string)
  default     = []
  description = "Additional namepaces to observe with Traefik, default is only observe the name_prefix namespace."
}

# forwardauth config.
variable "forwardauth_helm_chart_version" {}
variable "forwardauth_auth0_domain" {}
