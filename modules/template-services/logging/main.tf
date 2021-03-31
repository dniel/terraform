######################################################
# Install ElasticCloud on K8s for centralized logging.
# https://github.com/elastic/cloud-on-k8s
#
# This module is a little bit special beacuse its the
# only module that use banzaicloud/k8s to apply
# manifests instead of kubernetes-alpha from hashicorp.
#
# The reason for that is the alpha provider didnt work
# well with the provider to create new resources and
# using the terraform plan with dry-run.
######################################################
locals {
  labels = merge(var.labels, {
  })
  forwardauth_middleware_namespace = var.name_prefix
  forwardauth_middleware_name      = "forwardauth-authorize"
}

# TODO implement a more lightweight centralized logging than ElasticCloud.