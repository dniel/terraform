output "dns_name" {
  value       = "spin.${var.domain_name}"
  description = "The hostname where the webapp is accessible."
}
