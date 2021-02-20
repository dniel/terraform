# used to give traefik access to route53 to do ACME letencrypt certificates.
data "aws_secretsmanager_secret_version" "traefik" {
  secret_id = "traefik"
}

# auth0 credentials
data "aws_secretsmanager_secret_version" "auth0" {
  secret_id = "auth0"
}

locals {
  auth0_client_id                    = jsondecode(data.aws_secretsmanager_secret_version.auth0.secret_string)["client_id"]
  auth0_client_secret                = jsondecode(data.aws_secretsmanager_secret_version.auth0.secret_string)["client_secret"]
  auth0_domain                       = "dniel.eu.auth0.com"
  kube_context                       = "juju-context"
  kube_config                        = "~/.kube/config"
  aws_region                         = "eu-north-1"
  name_prefix                        = "dev"
  base_domain_name                   = "dniel.in"
  load_balancer_public_ip            = ""
  load_balancer_alias_hosted_zone_id = ""
  load_balancer_alias_dns_name       = "dniel.chickenkiller.com"
  primary_hosted_zone_id             = "Z25Z86AZE76SY4"
  traefik_aws_access_key             = jsondecode(data.aws_secretsmanager_secret_version.traefik.secret_string)["access_key"]
  traefik_aws_secret_key             = jsondecode(data.aws_secretsmanager_secret_version.traefik.secret_string)["secret_key"]
  traefik_websecure_port             = 31443
  traefik_service_type               = "NodePort"
  traefik_default_tls_secretName     = "traefik-default-tls"
  traefik_helm_chart_version         = "9.12.3"
  traefik_pilot_token                = ""
  forwardauth_helm_chart_version     = "2.0.13"
}

#########################################
#
#
#########################################
provider "auth0" {
  domain        = local.auth0_domain
  client_id     = local.auth0_client_id
  client_secret = local.auth0_client_secret
}
provider "kubernetes" {
  config_context = local.kube_context
  config_path    = local.kube_config
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
  source           = "../../modules/template"
  base_domain_name = local.base_domain_name
  name_prefix      = local.name_prefix

  # parameters for traefik
  traefik_websecure_port         = local.traefik_websecure_port
  traefik_service_type           = local.traefik_service_type
  traefik_default_tls_secretName = local.traefik_default_tls_secretName
  traefik_pilot_token            = local.traefik_pilot_token
  forwardauth_auth0_domain       = local.auth0_domain

  load_balancer_public_ip            = local.load_balancer_public_ip
  load_balancer_alias_dns_name       = local.load_balancer_alias_dns_name
  load_balancer_alias_hosted_zone_id = local.load_balancer_alias_hosted_zone_id
  primary_hosted_zone_id             = local.primary_hosted_zone_id

  traefik_aws_access_key = local.traefik_aws_access_key
  traefik_aws_secret_key = local.traefik_aws_secret_key

  forwardauth_helm_chart_version = local.forwardauth_helm_chart_version
  traefik_helm_chart_version     = local.traefik_helm_chart_version
}

