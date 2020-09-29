variable "certificates_aws_access_key" {}
variable "certificates_aws_secret_key" {}
variable "auth0_domain" {}
variable "traefik_pilot_token" {}
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
variable "forwardauth_helm_chart_version" {}
variable "unifi_helm_chart_version" {}
variable "whoami_helm_chart_version" {}
variable "website_helm_chart_version" {}
variable "api_graphql_helm_chart_version" {}
variable "api_posts_helm_chart_version" {}
variable "spa_demo_helm_chart_version" {}
variable "certmanager_helm_release_version" {}

variable "feature_monitoring" {
  type = bool
  default = false
  description = "Enable/Disable installation of Prometheus and Grafana"
}

variable "feature_spinnaker" {
  type = bool
  default = false
  description = "Enable/Disable installation of Spinnaker"
}

variable "feature_vsphere" {
  type = bool
  default = false
  description = "Enable/Disable vsphere specific components."
}
