locals {
  domain_name = "${var.name_prefix}.${var.base_domain_name}"
  labels = {
    env = var.name_prefix
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
  source      = "../base"
  domain_name = local.domain_name
  name_prefix = var.name_prefix
  labels      = local.labels

  # parameters for forwardauth
  forwardauth_helm_release_version = var.forwardauth_helm_chart_version
  forwardauth_tenant               = var.auth0_domain

  # parameters for traefik
  traefik_helm_release_version   = var.traefik_helm_chart_version
  traefik_websecure_port         = var.traefik_websecure_port
  traefik_service_type           = var.traefik_service_type
  traefik_default_tls_secretName = var.traefik_default_tls_secretName
  traefik_pilot_token            = var.traefik_pilot_token

  # parameters for dns and loadbalancer infront of cluster.
  # name of the ELB load balancer dns record infront of kubernetes.
  load_balancer_public_ip            = var.load_balancer_public_ip
  load_balancer_alias_dns_name       = var.load_balancer_alias_dns_name
  load_balancer_alias_hosted_zone_id = var.load_balancer_alias_hosted_zone_id
  primary_hosted_zone_id             = var.primary_hosted_zone_id

  # DNS names to be registered and pointed to the public load balancer ip.
  dns_names = [
    #    module.apps.api_graphql_dns_name,
    #    module.apps.api_posts_dns_name,
    #    module.apps.whoami_dns_name,
    #    module.apps.www_dns_name,
    #    module.apps.spa_demo_dns_name
  ]

  certificates_aws_access_key = var.certificates_aws_access_key
  certificates_aws_secret_key = var.certificates_aws_secret_key
}

#################################################################
# Specific features installed in Internal environment
#
#################################################################
/*
module "apps" {
  source      = "../apps"
  domain_name = local.domain_name
  name_prefix = var.name_prefix
  namespace   = module.base.namespace
  labels      = var.labels

  api_graphql_helm_release_version = var.api_graphql_helm_chart_version
  api_posts_helm_release_version   = var.api_posts_helm_chart_version
  website_helm_release_version     = var.website_helm_chart_version
  whoami_helm_release_version      = var.whoami_helm_chart_version
  spa_demo_helm_release_version    = var.spa_demo_helm_chart_version
}
*/