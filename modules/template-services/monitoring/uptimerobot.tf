# auth0 credentials
data "aws_secretsmanager_secret_version" "uptimerobot" {
  secret_id = "uptimerobot"
}

# Prometheus Exporter for the official uptimerobot CLI
resource "helm_release" "uptimerobot-prometheus" {
  name       = "uptimerobot-prometheus"
  repository = "https://k8s-at-home.com/charts/"
  chart      = "uptimerobot-prometheus"
  namespace  = var.name_prefix
  version    = "4.1.0"

  # API key used for uptimerobot stored in AWS Secrets Manager.
  set {
    name  = "env.UPTIMEROBOT_API_KEY"
    value = data.aws_secretsmanager_secret_version.uptimerobot.secret_string
  }
}