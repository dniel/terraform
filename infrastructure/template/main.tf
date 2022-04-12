locals {
  labels = {
    env = var.name_prefix
  }
}


##################################################################################
# Just to make sure that we have the environment namespace that must be
# created before deploying an environment. This is not created by
# the terraform script.
# trigger
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
  traefik_observe_namespaces   = var.traefik_observe_namespaces

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

  # if load balancer alias is manually specified, use that
  # else use the hostname comming out of the ingres object
  # from traefik ingress router.
  load_balancer_alias_dns_name = (
    length(var.load_balancer_alias_dns_name)>0 ?
    var.load_balancer_alias_dns_name :
    module.traefik.traefik_load_balancer_ingress[0].hostname
  )

  # the primary hosted zone if the new zone if a nested zone.
  primary_hosted_zone_id = var.primary_hosted_zone_id
}