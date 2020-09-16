output "namespace" {
  value       = data.kubernetes_namespace.env_namespace
  description = "The kubernetes namespace for the environment."
}