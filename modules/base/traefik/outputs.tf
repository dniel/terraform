output "dns_name" {
  value       = "traefik.${var.domain_name}"
  description = "The hostname where the Traefik Dashboard is accessible."
}