output "dns_name" {
  value       = "traefik.${var.domain_name}"
  description = "The hostname where the Traefik Dashboard is accessible."
}

output "namespace" {
  value       = kubernetes_namespace.traefik.id
  description = "The namespace where Traefik was installed."
}
