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

#########################################
#
#
#########################################
locals {
  load_balancer_public_ip = "10.0.50.165"
  domain_name             = "demo.dniel.in"
  name_prefix             = "demo"

  traefik_helm_chart_version     = "7.2.0"
  traefik_default_tls_secretName = "traefik-default-tls"
  traefik_websecure_port         = 31443
  traefik_service_type           = "NodePort"

  unifi_helm_chart_version       = "0.6.5"
  whoami_helm_chart_version      = "0.3"
  website_helm_chart_version     = "0.3"
  api_graphql_helm_chart_version = "0.4"
  api_posts_helm_chart_version   = "0.4"

  forwardauth_helm_chart_version = "2.0.8"
  forwardauth_clientid           = var.forwardauth_clientid
  forwardauth_clientsecret       = var.forwardauth_clientsecret
  forwardauth_audience           = "https://${local.domain_name}"

  certificates_aws_access_key = var.certificates_aws_access_key
  certificates_aws_secret_key = var.certificates_aws_secret_key
  primary_hosted_zone_id      = "Z25Z86AZE76SY4"

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
  forwardauth_clientid             = "v1VM3YPVe7gdUELae1or2y7O1Mk3UAbx"
  forwardauth_clientsecret         = "avejbRMB1gWFgBGl1KESv_jb1gSr0eKNvxoHIhD4jkRlv4pyCsT7WXG5eKF0KntP"
  forwardauth_audience             = "https://${local.domain_name}"
  forwardauth_token_cookie_domain  = local.domain_name
  forwardauth_helm_release_version = local.forwardauth_helm_chart_version

  # parameters for traefik
  traefik_helm_release_version   = local.traefik_helm_chart_version
  traefik_websecure_port         = local.traefik_websecure_port
  traefik_service_type           = local.traefik_service_type
  traefik_default_tls_secretName = local.traefik_default_tls_secretName

  # parameter for public ip where appliactions will be accessed.
  load_balancer_public_ip = local.load_balancer_public_ip

  # DNS names to be registered and pointed to the public load balancer ip.
  dns_names = [
    module.apps.api_graphql_dns_name,
    module.apps.api_posts_dns_name,
    module.apps.whoami_dns_name,
    module.apps.www_dns_name
  ]

  certificates_aws_access_key = local.certificates_aws_access_key
  certificates_aws_secret_key = local.certificates_aws_secret_key

  # The primary hosted zone to add NS records for the nested zone.
  primary_hosted_zone_id = local.primary_hosted_zone_id
}

#################################################################
# Common applications installed in all environments.
#
#################################################################
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
