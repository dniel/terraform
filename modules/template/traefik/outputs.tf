output "dns_name" {
  value       = "traefik.${var.domain_name}"
  description = "The hostname where the Traefik Dashboard is accessible."
}

output "traefik_load_balancer_ingress_hostname" {
  value       = data.kubernetes_service.traefik.status[0].load_balancer[0].ingress[0].hostname
  description = "Hostname which is set for load-balancer ingress points that are DNS based."
}