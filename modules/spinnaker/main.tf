#####################################################################
# configure spinnaker
#
# TODO
# - add spinnaker terraform provider to create pipelines and stuff
#
####################################################################
locals {
  service_account_name = "pipeline-cleanup-sa"
  pipeline_namespace = "pipeline"
  cleanup_cronjob_schedule = "*/30 * * * *"
}

locals {
  app_name = "spinnaker"
  labels = merge(var.labels, {
    "app" = local.app_name
  })
  forwardauth_middleware_namespace = var.name_prefix
  forwardauth_middleware_name      = "forwardauth-authorize"
}

resource "kubernetes_namespace" "pipeline" {
  metadata {
    name = local.pipeline_namespace
  }
}

data "kubernetes_namespace" "spinnaker" {
  metadata {
    name = "spinnaker"
  }
}

# IAM User to use when running pipeline terraform jobs.
resource "aws_iam_user" "pipeline_job_user" {
  name = "${var.name_prefix}-pipeline"
  path = "/system/"

  tags = local.labels
}

# Create Access Key for IAM User.
resource "aws_iam_access_key" "pipeline_user_access_key" {
  user = aws_iam_user.pipeline_job_user.name
}

# the access key id
resource "aws_ssm_parameter" "aws_credentials_id" {
  name = "/spinnaker/aws_credentials/key"
  type  = "String"
  value = aws_iam_access_key.pipeline_user_access_key.id
}

# the access key secret
resource "aws_ssm_parameter" "aws_credentials_secret" {
  name = "/spinnaker/aws_credentials/secret"
  type  = "String"
  value = aws_iam_access_key.pipeline_user_access_key.secret
}

# Store the access key and id as a secret in kubernetes.
resource "kubernetes_secret" "external_secrets_secret" {
  metadata {
    name = "pipeline-aws-credentials"
    namespace = "spinnaker"
  }
  data = {
    id = aws_iam_access_key.pipeline_user_access_key.id
    secret = aws_iam_access_key.pipeline_user_access_key.secret
    region = "eu-north-1"
  }
  type = "Opaque"
}

resource "kubernetes_manifest" "middleware_strip_api_prefix" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" : "traefik.containo.us/v1alpha1"
    "kind" : "Middleware"
    "metadata" : {
      "labels" : local.labels
      "namespace" : "spinnaker"
      "name" : "strip-api-prefix"
    }
    "spec" : {
      "stripPrefix" : {
        "prefixes" : [
          "/api"
        ]
      }
    }
  }
}

######################################################
# expose spinnaker api
#
######################################################
resource "kubernetes_manifest" "spinnaker_gate_ingressroute" {
  provider = kubernetes-alpha

  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "annotations" = {
        "kubernetes.io/ingress.class" = "traefik-${var.name_prefix}"
      },
      "namespace" = "services"
      "labels"    = local.labels
      "name"      = "spin-gate"
    }
    "spec" = {
      "entryPoints" = [
        "websecure",
      ]
      "routes" = [
        {
          "kind"  = "Rule"
          "match" = "Host(`spin.${var.domain_name}`) && PathPrefix(`/api`)"
          "middlewares" = [
            {
              "name"      = "strip-api-prefix"
              "namespace" = "spinnaker"
            },
            {
              "name"      = local.forwardauth_middleware_name
              "namespace" = local.forwardauth_middleware_namespace
            }
          ]
          "services" = [
            {
              "name"      = "spin-gate"
              "port"      = 8084
              "namespace" = "spinnaker"
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
# expose spinnaker ui
#
######################################################
resource "kubernetes_manifest" "spinnaker_deck_ingressroute" {
  provider = kubernetes-alpha

  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "annotations" = {
        "kubernetes.io/ingress.class" = "traefik-${var.name_prefix}"
      },
      "namespace" = "services"
      "labels"    = local.labels
      "name"      = "spin-deck"
    }
    "spec" = {
      "entryPoints" = [
        "websecure",
      ]
      "routes" = [
        {
          "kind"  = "Rule"
          "match" = "Host(`spin.${var.domain_name}`)"
          "middlewares" = [
            {
              "name"      = local.forwardauth_middleware_name
              "namespace" = local.forwardauth_middleware_namespace
            }
          ]
          "services" = [
            {
              "name"      = "spin-deck"
              "port"      = 9000
              "namespace" = "spinnaker"
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

