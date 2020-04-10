output "dns_name" {
  value       = "auth.${var.domain_name}"
  description = "The hostname where the webapp is accessible."
}
