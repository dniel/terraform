output "whoami_dns_name" {
  value       = "whoami.${var.domain_name}"
  description = "The hostname where the webapp is accessible."
}

output "www_dns_name" {
  value       = "www.${var.domain_name}"
  description = "The hostname where the webapp is accessible."
}

output "api_posts_dns_name" {
  value       = "api-posts.${var.domain_name}"
  description = "The hostname where the webapp is accessible."
}

output "api_graphql_dns_name" {
  value       = "api-graphql.${var.domain_name}"
  description = "The hostname where the webapp is accessible."
}

output "spa_demo_dns_name" {
  value       = "spa-demo.${var.domain_name}"
  description = "The hostname where the webapp is accessible."
}
