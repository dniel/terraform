output "dns_name" {
  value       = "ubnt.${var.domain_name}"
  description = "The hostname where the webapp is accessible."
}
