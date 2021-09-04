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

##################################
# Docs
#
##################################
module "docs" {
  source      = "github.com/dniel/terraform?ref=master/modules/docs"
  name_prefix = local.name_prefix
  domain_name = "${local.name_prefix}.${local.domain_name}"
}

# Create K8s Service with Externalname to use for ingressroutes.
resource "kubernetes_manifest" "docs-external-website-service" {
  provider   = kubernetes-alpha

  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "namespace" = local.name_prefix
      "name"      = "docs-external"
      "annotations" = {
        "kubernetes.io/ingress.class" = "traefik-${local.name_prefix}"
      }
    }
    "spec" = {
      "entryPoints" = ["websecure"]
      "routes" = [
        {
          "kind" = "Rule"
          "match" = "Host(`docs.services.nordlab.io`)"
          "services" = [
            {
              "kind" = "Service"
              "name" = "docs-external-website"
              "namespace" = local.name_prefix
              "passHostHeader" = false
              "port" = 80
              "scheme" = "http"
            }
          ]
        }
      ]
      "tls" = {
        "certResolver" = "default"
      }
    }
  }
}