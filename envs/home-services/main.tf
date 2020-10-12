#########################################
#
#
#########################################
provider "auth0" {
  domain        = var.auth0_domain
  client_id     = var.auth0_client_id
  client_secret = var.auth0_client_secret
}
provider "kubernetes" {
  config_context = var.kube_context
}
provider "kubernetes-alpha" {
  config_context = var.kube_context
  config_path    = var.kube_config
}
provider "helm" {
  kubernetes {
    config_context = var.kube_context
  }
}
provider "aws" {
  region = var.aws_region
}

#########################################
#
#
#########################################
module "template" {
  source           = "../../modules/template"
  base_domain_name = var.base_domain_name
  name_prefix      = var.name_prefix

  # parameters for traefik
  traefik_websecure_port         = var.traefik_websecure_port
  traefik_service_type           = var.traefik_service_type
  traefik_default_tls_secretName = var.traefik_default_tls_secretName
  traefik_pilot_token            = var.traefik_pilot_token
  traefik_aws_access_key         = var.traefik_aws_access_key
  traefik_aws_secret_key         = var.traefik_aws_secret_key
  traefik_helm_chart_version     = var.traefik_helm_chart_version

  # DNS configuration and load balancer parameters.
  load_balancer_public_ip            = var.load_balancer_public_ip
  load_balancer_alias_dns_name       = var.load_balancer_alias_dns_name
  load_balancer_alias_hosted_zone_id = var.load_balancer_alias_hosted_zone_id
  primary_hosted_zone_id             = var.primary_hosted_zone_id

  # Forwardauth parameters
  forwardauth_helm_chart_version = var.forwardauth_helm_chart_version
  forwardauth_auth0_domain       = var.auth0_domain

}

#########################################
#
#
#########################################
module "template-services" {
  source           = "../../modules/template-services"
  base_domain_name = var.base_domain_name
  name_prefix      = var.name_prefix
  hosted_zone_id   = module.template.hosted_zone_id

  feature_monitoring = true
  feature_spinnaker  = true
  feature_vsphere    = true

  unifi_helm_release_version = "1.0.0"
  unifi_image_tag            = "stable-6"
}
