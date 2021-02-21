locals {
  labels = {
    env = var.name_prefix
  }
}


##################################################################################
# Just to make sure that we have the environment namespace that must be
# created before deploying an environment. This is not created by
# the terraform script.
##################################################################################
data "kubernetes_namespace" "env_namespace" {
  metadata {
    name   = var.name_prefix
    labels = local.labels
  }
}

##################################################################################
# Deploy Traefik ingress controller
#
##################################################################################
module "traefik" {
  source      = "./traefik"
  domain_name = var.domain_name
  name_prefix = var.name_prefix
  labels      = local.labels
  namespace   = data.kubernetes_namespace.env_namespace

  traefik_helm_release_version = var.traefik_helm_chart_version
  traefik_websecure_port       = var.traefik_websecure_port
  traefik_service_type         = var.traefik_service_type
  traefik_pilot_token          = var.traefik_pilot_token

  aws_access_key        = var.traefik_aws_access_key
  aws_secret_access_key = var.traefik_aws_secret_key
  aws_hosted_zone_id    = module.dns.hosted_zone_id
}

##################################################################################
# Deploy ForwardAuth in all environments.
#
##################################################################################
module "forwardauth" {
  source      = "./forwardauth"
  domain_name = var.domain_name
  name_prefix = var.name_prefix
  labels      = local.labels
  namespace   = data.kubernetes_namespace.env_namespace

  forwardauth_helm_release_version = var.forwardauth_helm_chart_version
  forwardauth_tenant               = var.forwardauth_auth0_domain
}

##################################################################################
# Configure central DNS settings for environment.
#
##################################################################################
module "dns" {
  source      = "./dns"
  domain_name = var.domain_name
  name_prefix = var.name_prefix
  labels      = local.labels
  namespace   = data.kubernetes_namespace.env_namespace

  # TODO remove, deprecated.
  dns_names = []

  # if service is of type load balancer, use the load balancer dns name as alias for dns.
  load_balancer_alias_dns_name = (
    lower(var.traefik_service_type) == "loadbalancer" ?
    module.traefik.traefik_load_balancer_ingress[0].hostname :
    var.load_balancer_alias_dns_name
  )

  # the primary hosted zone if the new zone if a nested zone.
  primary_hosted_zone_id = var.primary_hosted_zone_id
}