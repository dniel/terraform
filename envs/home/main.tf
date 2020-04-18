#########################################
#
#
#########################################
provider "kubernetes" {
  config_context = "juju-context"
}
provider "helm" {
  kubernetes {
    config_context = "juju-context"
  }
}
provider "k8s" {
  config_context = "juju-context"
}
provider "aws" {
  version = "~> 2.0"
  region  = "eu-central-1"
}


locals {
  domain_name = "dniel.in"
  name_prefix = "home"

  load_balancer_public_ip = "10.0.50.165"

  traefik_websecure_port         = 32443
  traefik_service_type           = "NodePort"
  traefik_default_tls_secretName = "traefik-default-tls"
  traefik_helm_chart_version     = "6.2.0"

  forwardauth_helm_chart_version = "2.0.8"
  forwardauth_tenant             = "dniel.eu.auth0.com"
  forwardauth_clientid           = var.forwardauth_clientid
  forwardauth_clientsecret       = var.forwardauth_clientsecret
  forwardauth_audience           = "https://${local.domain_name}"

  certificates_aws_access_key = var.certificates_aws_access_key
  certificates_aws_secret_key = var.certificates_aws_secret_key

  unifi_helm_chart_version         = "0.6.5"
  whoami_helm_chart_version        = "0.4"
  website_helm_chart_version       = "0.4"
  api_graphql_helm_chart_version   = "0.5"
  api_posts_helm_chart_version     = "0.5"
  certmanager_helm_release_version = "0.14.1"

  labels = {
    env = local.name_prefix
  }
}

#################################################################
# Basic features installed in all environments.
# For example
# - traefik
# - forwardauth
# - dns
# - certificates
#
#################################################################
module "base" {
  source      = "../../modules/base"
  domain_name = local.domain_name
  name_prefix = local.name_prefix
  labels      = local.labels

  # parameters for forwardauth
  forwardauth_clientid             = local.forwardauth_clientid
  forwardauth_clientsecret         = local.forwardauth_clientsecret
  forwardauth_audience             = local.forwardauth_audience
  forwardauth_token_cookie_domain  = local.domain_name
  forwardauth_helm_release_version = local.forwardauth_helm_chart_version
  forwardauth_tenant               = local.forwardauth_tenant

  # parameters for traefik
  traefik_helm_release_version   = local.traefik_helm_chart_version
  traefik_websecure_port         = local.traefik_websecure_port
  traefik_service_type           = local.traefik_service_type
  traefik_default_tls_secretName = local.traefik_default_tls_secretName

  # parameter for public ip where appliactions will be accessed.
  load_balancer_public_ip = local.load_balancer_public_ip

  # DNS names to be registered and pointed to the public load balancer ip.
  dns_names = [
    module.unifi.dns_name,
    module.spinnaker.dns_name,
    module.apps.api_graphql_dns_name,
    module.apps.api_posts_dns_name,
    module.apps.whoami_dns_name,
    module.apps.www_dns_name
  ]

  certificates_aws_access_key = local.certificates_aws_access_key
  certificates_aws_secret_key = local.certificates_aws_secret_key
}

#################################################################
# Specific features installed in Internal environment
#
#################################################################
module "unifi" {
  source      = "../../modules/unifi"
  domain_name = local.domain_name
  name_prefix = local.name_prefix
  labels      = local.labels

  unifi_helm_release_version = local.unifi_helm_chart_version
}

module "spinnaker" {
  source      = "../../modules/spinnaker"
  domain_name = local.domain_name
  name_prefix = local.name_prefix
  labels      = local.labels
}

module "vsphere" {
  source      = "../../modules/vsphere"
  domain_name = local.domain_name
  name_prefix = local.name_prefix
  labels      = local.labels
}

module "certmanager" {
  source      = "../../modules/certmanager"
  domain_name = local.domain_name
  name_prefix = local.name_prefix
  labels      = local.labels

  certmanager_helm_release_version = local.certmanager_helm_release_version
}

module "apps" {
  source                           = "../../modules/apps"
  domain_name                      = local.domain_name
  name_prefix                      = local.name_prefix
  labels                           = local.labels
  api_graphql_helm_release_version = local.api_graphql_helm_chart_version
  api_posts_helm_release_version   = local.api_posts_helm_chart_version
  website_helm_release_version     = local.website_helm_chart_version
  whoami_helm_release_version      = local.whoami_helm_chart_version
}
