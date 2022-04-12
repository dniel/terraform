output "namespace" {
  value       = data.kubernetes_namespace.env_namespace
  description = "The kubernetes namespace for the environment."
}

output "hosted_zone_id" {
  value       = module.dns.hosted_zone_id
  description = "The ID of the hosted zone where dns record was created."
}