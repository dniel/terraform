variable "auth0_domain" {}
variable "auth0_client_id" {}
variable "auth0_client_secret" {}
variable "traefik_pilot_token" {}
variable "kube_context" {}
variable "kube_config" {}
variable "aws_region" {}
variable "base_domain_name" {}
variable "name_prefix" {}
variable "load_balancer_public_ip" {}
variable "load_balancer_alias_hosted_zone_id" {}
variable "load_balancer_alias_dns_name" {}
variable "primary_hosted_zone_id" {}
variable "traefik_websecure_port" {}
variable "traefik_service_type" {}
variable "traefik_default_tls_secretName" {}
variable "traefik_helm_chart_version" {}
variable "traefik_aws_access_key" {}
variable "traefik_aws_secret_key" {}
variable "forwardauth_helm_chart_version" {}