output "namespace" {
  value       = kubernetes_namespace.base-namespace
  description = "The kubernetes namespace for the environment."
}