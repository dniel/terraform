# used to give traefik access to route53 to do ACME letencrypt certificates.
data "aws_secretsmanager_secret_version" "traefik" {
  secret_id = "traefik"
}

# auth0 credentials
data "aws_secretsmanager_secret_version" "auth0" {
  secret_id = "auth0"
}
locals {
  auth0_domain                       = "dniel.eu.auth0.com"
  auth0_client_id                    = jsondecode(data.aws_secretsmanager_secret_version.auth0.secret_string)["client_id"]
  auth0_client_secret                = jsondecode(data.aws_secretsmanager_secret_version.auth0.secret_string)["client_secret"]
  kube_context                       = "tkg-test-01"
  kube_config                        = "~/.kube/config"
  aws_region                         = "eu-north-1"
  name_prefix                        = "services"
  domain_name                        = "${local.name_prefix}.nordlab.io"
  load_balancer_public_ip            = ""
  load_balancer_alias_hosted_zone_id = ""
  load_balancer_alias_dns_name       = "dniel.chickenkiller.com"
  primary_hosted_zone_id             = "Z0377759ONY4I87XFN01"
  traefik_websecure_port             = 32443
  traefik_service_type               = "LoadBalancer"
  traefik_default_tls_secretName     = "traefik-default-tls"
  traefik_helm_chart_version         = "9.19.1"
  traefik_aws_access_key             = jsondecode(data.aws_secretsmanager_secret_version.traefik.secret_string)["access_key"]
  traefik_aws_secret_key             = jsondecode(data.aws_secretsmanager_secret_version.traefik.secret_string)["secret_key"]
  traefik_pilot_token                = "685b7f76-2f1e-4f30-8b00-8e54e58ce6a8"
  forwardauth_helm_chart_version     = "2.0.13"
}

#########################################
#
#
#########################################
provider "k8s" {
  config_context = local.kube_context
  config_path    = local.kube_config
}
provider "auth0" {
  domain        = local.auth0_domain
  client_id     = local.auth0_client_id
  client_secret = local.auth0_client_secret
}
provider "kubernetes" {
  config_context = local.kube_context
  config_path    = local.kube_config
  experiments {
    manifest_resource = true
  }
}
provider "kubernetes-alpha" {
  config_context = local.kube_context
  config_path    = local.kube_config
}
provider "helm" {
  kubernetes {
    config_context = local.kube_context
    config_path    = local.kube_config
  }
}
provider "aws" {
  region = local.aws_region
}

#########################################
#
#
#########################################
module "template" {
  source      = "../../../infrastructure/template"
  domain_name = local.domain_name
  name_prefix = local.name_prefix

  # parameters for traefik
  traefik_websecure_port         = local.traefik_websecure_port
  traefik_service_type           = local.traefik_service_type
  traefik_default_tls_secretName = local.traefik_default_tls_secretName
  traefik_pilot_token            = local.traefik_pilot_token
  traefik_aws_access_key         = local.traefik_aws_access_key
  traefik_aws_secret_key         = local.traefik_aws_secret_key
  traefik_helm_chart_version     = local.traefik_helm_chart_version
  traefik_observe_namespaces     = ["spinnaker"]

  # DNS configuration and load balancer parameters.
  load_balancer_public_ip            = local.load_balancer_public_ip
  load_balancer_alias_dns_name       = local.load_balancer_alias_dns_name
  load_balancer_alias_hosted_zone_id = local.load_balancer_alias_hosted_zone_id
  primary_hosted_zone_id             = local.primary_hosted_zone_id

  # Forwardauth parameters
  forwardauth_helm_chart_version = local.forwardauth_helm_chart_version
  forwardauth_auth0_domain       = local.auth0_domain

}

#########################################
#
#
#########################################
module "template-services" {
  source         = "../../../infrastructure/template-services"
  domain_name    = local.domain_name
  name_prefix    = local.name_prefix
  hosted_zone_id = module.template.hosted_zone_id

  feature_spinnaker  = true
  feature_vsphere    = false

  unifi_helm_release_version = "1.0.0"
  unifi_image_tag            = "stable-6"
}
