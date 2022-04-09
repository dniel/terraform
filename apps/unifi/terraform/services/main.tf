locals {
  auth0_client_id     = jsondecode(data.aws_secretsmanager_secret_version.auth0.secret_string)["client_id"]
  auth0_client_secret = jsondecode(data.aws_secretsmanager_secret_version.auth0.secret_string)["client_secret"]
  auth0_domain        = "dniel.eu.auth0.com"
  kube_context        = "tkg-test-01"
  kube_config         = "~/.kube/config"
  aws_region          = "eu-north-1"
  name_prefix         = "services"
  domain_name         = "nordlab.io"
  tags                = {}
  name                = "unifi"
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
  source                = "github.com/dniel/terraform?ref=master/modules/unifi"
  name_prefix           = local.name_prefix
  domain_name           = "${local.name_prefix}.${local.domain_name}"
  unifi_chart_version   = "4.7.0"
  unifi_chart_image_tag = "v6.5.55"
  name                  = "unifi"
}

######################################################
# expose Unifi Controller UI.
#
######################################################
resource "kubernetes_manifest" "unifi_gui_ingressroute" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "annotations" = {
        "kubernetes.io/ingress.class" = "traefik-${local.name_prefix}"
      },
      "namespace" = local.name_prefix
      "name"      = "${local.name}-gui"
    }
    "spec" = {
      "entryPoints" = [
        "websecure",
      ]
      "routes" = [
        {
          "kind"  = "Rule"
          "match" = "Host(`${local.name}.${local.name_prefix}.${local.domain_name}`)"
          "services" = [
            {
              "name" = local.name
              "port" = 8443
              "scheme" = "https"
            },
          ]
        },
      ]
      "tls" = {
        "certResolver" = "default"
      }
    }
  }
}

######################################################
# expose Unifi Controller UI.
#
######################################################

resource "kubernetes_manifest" "unifi_inform_ingressroute" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "annotations" = {
        "kubernetes.io/ingress.class" = "traefik-${local.name_prefix}"
      },
      "namespace" = local.name_prefix
      "name"      = "${local.name}-inform"
    }
    "spec" = {
      "entryPoints" = [
        "web",
      ]
      "routes" = [
        {
          "kind"  = "Rule"
          "match" = "Host(`${local.name}.${local.name_prefix}.${local.domain_name}`) && PathPrefix(`/inform`)"
          "services" = [
            {
              "name" = local.name
              "port" = 8080
            },
          ]
        },
      ]
    }
  }
}