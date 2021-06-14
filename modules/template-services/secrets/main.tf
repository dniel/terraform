######################################################
#
#
######################################################
data "aws_caller_identity" "current_account" {}
data "aws_region" "current_region" {}

locals {
  current_account_id = data.aws_caller_identity.current_account.account_id
  current_region = data.aws_region.current_region.id
  labels = {
    env = var.name_prefix
    app = "external-secrets"
  }
}
# this is a workaround for this module to use the correct provider
# https://github.com/banzaicloud/terraform-provider-k8s/issues/63
terraform {
  required_providers {
    k8s = {
      source  = "banzaicloud/k8s"
      version = ">=0.9.0"
    }
  }
}

# Create IAM user for external-secrets to read from SSM and SecretsManager
resource "aws_iam_user" "external_secrets_iam_user" {
  name = "${var.name_prefix}-external-secrets"
  path = "/system/"

  tags = local.labels
}

# Create Access Key user.
resource "aws_iam_access_key" "external_secrets_access_key" {
  user = aws_iam_user.external_secrets_iam_user.name
}

# Store the access key and id as a secret in kubernetes.
resource "kubernetes_secret" "external_secrets_secret" {
  metadata {
    name = "external-secrets-iam-user"
    namespace = var.name_prefix
  }
  data = {
    id = aws_iam_access_key.external_secrets_access_key.id
    key = aws_iam_access_key.external_secrets_access_key.secret
  }
  type = "Opaque"
}

# Deploy Helm Chart External Secrets
locals {
  secretKeyRef = trimprefix(kubernetes_secret.external_secrets_secret.id, "${var.name_prefix}/")
}
resource "helm_release" "external-secrets" {
  name       = "external-secrets"
  repository = "https://external-secrets.github.io/kubernetes-external-secrets/"
  chart      = "kubernetes-external-secrets"
  namespace  = var.name_prefix
  version    = "8.1.3"

  # set environment variables to generate certificates for using Lets Encrypt.
  set {
    name  = "env.AWS_REGION"
    value = local.current_region
  }

  # set envVarsFromSecret.AWS_ACCESS_KEY_ID
  set {
    name  = "envVarsFromSecret.AWS_ACCESS_KEY_ID.secretKeyRef"
    value = local.secretKeyRef
  }
  set {
    name  = "envVarsFromSecret.AWS_ACCESS_KEY_ID.key"
    value = "id"
  }

  # set envVarsFromSecret.AWS_SECRET_ACCESS_KEY
  set {
    name  = "envVarsFromSecret.AWS_SECRET_ACCESS_KEY.secretKeyRef"
    value = local.secretKeyRef
  }
  set {
    name  = "envVarsFromSecret.AWS_SECRET_ACCESS_KEY.key"
    value = "key"
  }
  set {
    name  = "serviceMonitor.enabled"
    value = "true"
  }

}

# Add Policy to IAM user so that it can read from SSM and SecretsManager.
resource "aws_iam_user_policy" "external_secrets_user_policy" {
  name = "${var.name_prefix}-external-secrets"
  user = aws_iam_user.external_secrets_iam_user.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ssm:GetParameter",
      "Resource": "arn:aws:ssm:${local.current_region}:${local.current_account_id}:parameter/${var.name_prefix}/*"
    }
  ]
}
EOF
}
