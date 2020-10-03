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
  auth0_domain                   = var.auth0_domain

  load_balancer_public_ip            = var.load_balancer_public_ip
  load_balancer_alias_dns_name       = var.load_balancer_alias_dns_name
  load_balancer_alias_hosted_zone_id = var.load_balancer_alias_hosted_zone_id
  primary_hosted_zone_id             = var.primary_hosted_zone_id

  certificates_aws_access_key = var.certificates_aws_access_key
  certificates_aws_secret_key = var.certificates_aws_secret_key

  forwardauth_helm_chart_version   = var.forwardauth_helm_chart_version
  traefik_helm_chart_version       = var.traefik_helm_chart_version
}

#########################################
#
#
#########################################
module "template-services" {
  source           = "../../modules/template-services"
  base_domain_name = var.base_domain_name
  name_prefix      = var.name_prefix
  hosted_zone_id = module.template.hosted_zone_id

  feature_monitoring               = true
  feature_spinnaker                = true
  feature_vsphere                  = true
}
