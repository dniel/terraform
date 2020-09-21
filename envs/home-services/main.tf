#########################################
#
#
#########################################
terraform {
  required_version = ">0.13.0"
  #  backend "s3" {
  #    key            = "home/main.tfstate"
  #    bucket         = "xxx"
  #    dynamodb_table = "xxx"
  #    acl            = "bucket-owner-full-control"
  #    encrypt        = "true"
  #    kms_key_id     = "xxx"
  #    region         = "eu-west-1"
  #  }
}

provider "auth0" {
  domain        = var.auth0_domain
  client_id     = var.auth0_client_id
  client_secret = var.auth0_client_secret
}

provider "kubernetes" {
  config_context = "juju-context"
}
provider "kubernetes-alpha" {
  config_context = "juju-context"
  config_path    = "~/.kube/config"
}
provider "helm" {
  kubernetes {
    config_context = "juju-context"
  }
}
provider "aws" {
  version = "~> 3.0"
  region  = "eu-central-1"
}

locals {
  name_prefix = "common"
  domain_name = "${local.name_prefix}.dniel.in"

  load_balancer_alias_hosted_zone_id = "Z23TAZ6LKFMNIO"
  load_balancer_public_ip            = "10.0.50.165"
  dns_primary_hosted_zone_id         = "Z25Z86AZE76SY4"

  traefik_websecure_port         = 32443
  traefik_service_type           = "NodePort"
  traefik_default_tls_secretName = "traefik-default-tls"
  traefik_helm_chart_version     = "9.1.1"

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
  certmanager_helm_release_version = "1.0.1"

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
# TODO
# - alerting
# - monitoring
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

  # parameter for public ip where appliactions will be accessed.
  load_balancer_public_ip = local.load_balancer_public_ip
  primary_hosted_zone_id  = local.dns_primary_hosted_zone_id

  # DNS names to be registered and pointed to the public load balancer ip.
  dns_names = [
    module.spinnaker.dns_name,
  ]

  certificates_aws_access_key = local.certificates_aws_access_key
  certificates_aws_secret_key = local.certificates_aws_secret_key
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
