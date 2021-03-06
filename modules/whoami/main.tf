#############################################
#
#
#############################################
module "whoami" {
  source      = "github.com/dniel/terraform?ref=master/modules/helm-app"
  name_prefix = var.name_prefix
  domain_name = var.domain_name

  repository = "https://dniel.github.io/charts"

  name          = "whoami"
  chart         = "whoami"
  chart_version = "0.8.1"

  # Custom values for Chart.
  values = [
    {
      name  = "ingressroute.enabled"
      value = "true"
    },
    {
      name  = "ingressroute.annotations.kubernetes\\.io/ingress\\.class"
      value = "traefik-${var.name_prefix}"
    },
    {
      name  = "ingressroute.hostname"
      value = "whoami.${var.domain_name}"
    }
  ]
}