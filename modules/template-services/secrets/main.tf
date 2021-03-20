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

# Deploy External-Secrets controller using the credentials from above.
resource "kubernetes_manifest" "external-secrets-helm-release" {
  provider = kubernetes-alpha

  manifest = {
    "apiVersion" = "helm.fluxcd.io/v1"
    "kind" = "HelmRelease"
    "metadata" = {
      "name" = "external-secrets"
      "namespace" = var.name_prefix
      "labels" = var.labels
    }
    "spec" = {
      "chart" = {
        "repository" = "https://external-secrets.github.io/kubernetes-external-secrets/"
        "name" = "kubernetes-external-secrets"
        "version" = "6.4.0"

      }
      "skipCRDs" = true
      "values" = {
        "env" = {
          "AWS_REGION" = local.current_region
          "AWS_DEFAULT_REGION" = local.current_region
        },
        "envVarsFromSecret" = {
          "AWS_ACCESS_KEY_ID" = {
            "secretKeyRef" = trimprefix(kubernetes_secret.external_secrets_secret.id, "${var.name_prefix}/")
            "key" = "id"
          }
          "AWS_SECRET_ACCESS_KEY" = {
            "secretKeyRef" = trimprefix(kubernetes_secret.external_secrets_secret.id, "${var.name_prefix}/")
            "key" = "key"
          }
        }
      }
    }
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
    },
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds"
      ],
      "Resource": [
        "arn:aws:secretsmanager:${local.current_region}:${local.current_account_id}:secret:aes128-1a2b3c",
        "arn:aws:secretsmanager:${local.current_region}:${local.current_account_id}:secret:aes192-4D5e6F",
        "arn:aws:secretsmanager:${local.current_region}:${local.current_account_id}:secret:aes256-7g8H9i"
      ]
    }
  ]
}
EOF
}
