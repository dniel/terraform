resource "aws_route53_zone" "hosted_zone" {
  name = var.domain_name
  tags = var.labels
}

# Address record for external load balancer.
# The record that points to the external load balancer
# infront of kubernetes that load balances ingress requests
# between the different kubernetes worker nodes.
resource "aws_route53_record" "load_balancer_record" {
  count   = length(var.load_balancer_public_ip) > 0 ? 1 : 0
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "lb.${var.domain_name}"
  type    = "A"
  ttl     = "300"
  records = [var.load_balancer_public_ip]
}

# Alias record for external load balancer.
# The record that points to the external load balancer
# infront of kubernetes that load balances ingress requests
# between the different kubernetes worker nodes.
resource "aws_route53_record" "load_balancer_record_alias" {
  count   = length(var.load_balancer_alias_dns_name) > 0 ? 1 : 0
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "lb.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.load_balancer_alias_dns_name
    zone_id                = var.load_balancer_alias_hosted_zone_id
    evaluate_target_health = false
  }
}

# Create Alias A records for all domain names provided
# in the input list of domain names.
resource "aws_route53_record" "alias_record" {
  depends_on = [aws_route53_record.load_balancer_record_alias]
  for_each   = toset(var.dns_names)

  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = each.key
  type    = "A"

  alias {
    name                   = "lb.${var.domain_name}"
    zone_id                = aws_route53_zone.hosted_zone.id
    evaluate_target_health = false
  }
}

# Validate that the primary hosted zone if provided exists.
data aws_route53_zone "primary_hosted_zone" {
  count   = length(var.primary_hosted_zone_id) > 0 ? 1 : 0
  zone_id = var.primary_hosted_zone_id
}

# Add NS records to primary hosted zone for lookup
# if primary hosted zone id was provided as parameter.
resource "aws_route53_record" "nested-domain-ns" {
  depends_on = [data.aws_route53_zone.primary_hosted_zone]
  count      = length(var.primary_hosted_zone_id) > 0 ? 1 : 0
  zone_id    = data.aws_route53_zone.primary_hosted_zone[0].id
  name       = var.domain_name
  type       = "NS"
  ttl        = "30"

  records = [
    aws_route53_zone.hosted_zone.name_servers.0,
    aws_route53_zone.hosted_zone.name_servers.1,
    aws_route53_zone.hosted_zone.name_servers.2,
    aws_route53_zone.hosted_zone.name_servers.3,
  ]
}