locals {
  auth0_client_id     = jsondecode(data.aws_secretsmanager_secret_version.auth0.secret_string)["client_id"]
  auth0_client_secret = jsondecode(data.aws_secretsmanager_secret_version.auth0.secret_string)["client_secret"]
  auth0_domain        = "dniel.eu.auth0.com"
  kube_context        = "tkg-test-01"
  kube_config         = "~/.kube/config"
  aws_region          = "eu-north-1"
  name_prefix         = "services"
  domain_name         = "nordlab.io"
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
# Install Minecraft Java Server
#
#########################################
module "minecraft" {
  source                = "github.com/dniel/terraform?ref=master/modules/minecraft-server"
  name_prefix           = local.name_prefix
  domain_name           = "${local.name_prefix}.${local.domain_name}"
  server_version        = "1.17.1"
  server_motd           = "Welcome to the server"
  server_type           = "VANILLA"
  server_mode           = "creative"
# modpack_url
  world_url             = "https://198596758466-minecraft-modpacks.s3.eu-north-1.amazonaws.com/Oneblock%2B-%2BParty%2Bmode.zip"
}
