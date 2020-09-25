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
  config_context = "eks-dniel-prod"
}
provider "kubernetes-alpha" {
  config_context = "eks-dniel-prod"
  config_path    = "~/.kube/config"
}
provider "helm" {
  kubernetes {
    config_context = "eks-dniel-prod"
  }
}
provider "aws" {
  region = "eu-central-1"
}

locals {
  name_prefix = "cloud"
  domain_name = "${local.name_prefix}.dniel.se"

  load_balancer_alias_hosted_zone_id = "Z23TAZ6LKFMNIO"
  load_balancer_alias_dns_name       = "a80e90d0b72554b4cafc71562b8dcc29-781300914.eu-north-1.elb.amazonaws.com"
  dns_primary_hosted_zone_id         = "ZAIGXBQLLBZ7R"

  traefik_websecure_port         = 31443
  traefik_service_type           = "LoadBalancer"
  traefik_default_tls_secretName = "traefik-default-tls"
  traefik_helm_chart_version     = "9.3.0"
  traefik_pilot_token            = var.traefik_pilot_token

  forwardauth_helm_chart_version = "2.0.8"
  forwardauth_tenant             = var.auth0_domain

  certificates_aws_access_key = var.certificates_aws_access_key
  certificates_aws_secret_key = var.certificates_aws_secret_key

  unifi_helm_chart_version         = "0.6.5"
  whoami_helm_chart_version        = "0.4"
  website_helm_chart_version       = "0.4"
  api_graphql_helm_chart_version   = "0.5"
  api_posts_helm_chart_version     = "0.5"
  spa_demo_helm_chart_version      = "0.2"
  certmanager_helm_release_version = "0.14.1"

  labels = {
    env = local.name_prefix
  }
}

#################################################################
# Common features installed in all environments.
# For example
# - traefik
# - forwardauth
# - dns
# - certificates
#
# TODO
# - alerting
# - monitoring
# - logging
#
#################################################################
module "base" {
  source      = "../../modules/base"
  domain_name = local.domain_name
  name_prefix = local.name_prefix
  labels      = local.labels

  # parameters for forwardauth
  forwardauth_helm_release_version = local.forwardauth_helm_chart_version
  forwardauth_tenant               = local.forwardauth_tenant

  # parameters for traefik
  traefik_helm_release_version   = local.traefik_helm_chart_version
  traefik_websecure_port         = local.traefik_websecure_port
  traefik_service_type           = local.traefik_service_type
  traefik_default_tls_secretName = local.traefik_default_tls_secretName

  # parameters for dns
  # name of the ELB load balancer dns record infront of kubernetes.
  load_balancer_alias_dns_name       = local.load_balancer_alias_dns_name
  load_balancer_alias_hosted_zone_id = local.load_balancer_alias_hosted_zone_id
  primary_hosted_zone_id             = local.dns_primary_hosted_zone_id

  # DNS names to be registered and pointed to the public load balancer ip.
  dns_names = [
    #    module.apps.api_graphql_dns_name,
    #    module.apps.api_posts_dns_name,
    #    module.apps.whoami_dns_name,
    #    module.apps.www_dns_name,
    #    module.apps.spa_demo_dns_name
  ]

  certificates_aws_access_key = local.certificates_aws_access_key
  certificates_aws_secret_key = local.certificates_aws_secret_key
}

#################################################################
# Specific features installed in Internal environment
#
#################################################################
/*
module "apps" {
  source      = "../../modules/apps"
  domain_name = local.domain_name
  name_prefix = local.name_prefix
  namespace   = module.base.namespace
  labels      = local.labels

  api_graphql_helm_release_version = local.api_graphql_helm_chart_version
  api_posts_helm_release_version   = local.api_posts_helm_chart_version
  website_helm_release_version     = local.website_helm_chart_version
  whoami_helm_release_version      = local.whoami_helm_chart_version
  spa_demo_helm_release_version    = local.spa_demo_helm_chart_version
}
*/