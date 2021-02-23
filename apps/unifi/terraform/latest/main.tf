locals {
  auth0_client_id     = jsondecode(data.aws_secretsmanager_secret_version.auth0.secret_string)["client_id"]
  auth0_client_secret = jsondecode(data.aws_secretsmanager_secret_version.auth0.secret_string)["client_secret"]
  auth0_domain        = "dniel.eu.auth0.com"
  kube_context        = "juju-context"
  kube_config         = "~/.kube/config"
  aws_region          = "eu-north-1"
  name_prefix         = "services"
  domain_name         = "dniel.in"
}

# auth0 credentials
data "aws_secretsmanager_secret_version" "auth0" {
  secret_id = "auth0"
}

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
module "unifi" {
  source                = "../template"
  name_prefix           = local.name_prefix
  domain_name           = "${local.name_prefix}.${local.domain_name}"
  unifi_chart_version   = "1.5.1"
  unifi_chart_image_tag = "latest"
  name                  = "unifilatest"

  # dont install an additional unifi poller
  # in the same namespace because it already exists.
  install_unifi_poller = false
}

