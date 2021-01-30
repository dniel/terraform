locals {
  domain_name = "${var.name_prefix}.${var.base_domain_name}"
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
  domain_name = local.domain_name
  name_prefix = var.name_prefix
  labels      = local.labels
}

##################################
#
#
##################################
module "logging" {
  depends_on = [module.operators]
  source      = "./logging"
  domain_name = local.domain_name
  name_prefix = var.name_prefix
  labels      = local.labels

  hosted_zone_id = var.hosted_zone_id
}

##################################
#
#
##################################
//module "monitoring" {
//  depends_on = [module.operators]
//  count = var.feature_monitoring ? 1 : 0
//  source      = "./monitoring"
//  domain_name = local.domain_name
//  name_prefix = var.name_prefix
//  labels      = local.labels
//
//  hosted_zone_id = var.hosted_zone_id
//}

##################################
#
#
##################################
module "spinnaker" {
  depends_on = [module.operators]
  count = var.feature_spinnaker ? 1 : 0
  source      = "./spinnaker"
  domain_name = local.domain_name
  name_prefix = var.name_prefix
  labels      = local.labels

  hosted_zone_id = var.hosted_zone_id
}


##################################
#
#
##################################
module "vsphere" {
  count = var.feature_vsphere ? 1 : 0
  source      = "./vsphere"
  domain_name = local.domain_name
  name_prefix = var.name_prefix
  labels      = local.labels
}