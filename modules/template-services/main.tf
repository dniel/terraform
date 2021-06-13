locals {
  labels = {
    env = var.name_prefix
  }
}

##################################
#
#
##################################
module "operators" {
  source      = "./operators"
  domain_name = var.domain_name
  name_prefix = var.name_prefix
  labels      = local.labels
}

##################################
#
#
##################################
module "secrets" {
  depends_on  = [module.operators]
 source      = "./secrets"
  domain_name = var.domain_name
  name_prefix = var.name_prefix
  labels      = local.labels
}

##################################
#
#
##################################
module "logging" {
  depends_on  = [module.operators]
  source      = "./logging"
  domain_name = var.domain_name
  name_prefix = var.name_prefix
  labels      = local.labels

  hosted_zone_id = var.hosted_zone_id
}

##################################
#
#
##################################
module "monitoring" {
  depends_on  = [module.operators]
  source      = "./monitoring"
  domain_name = var.domain_name
  name_prefix = var.name_prefix
  labels      = local.labels

  kube_prometheus_stack_chart_version = var.kube_prometheus_stack_chart_version
}

##################################
#
#
##################################
module "storage" {
  depends_on  = [module.operators]
  source      = "./storage"
  domain_name = var.domain_name
  name_prefix = var.name_prefix
  labels      = local.labels
}

##################################
#
#
##################################
module "spinnaker" {
  count       = var.feature_spinnaker ? 1 : 0
  source      = "../spinnaker"
  domain_name = var.domain_name
  name_prefix = var.name_prefix
  labels      = local.labels

  hosted_zone_id = var.hosted_zone_id
}