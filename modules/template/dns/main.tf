resource "aws_route53_zone" "hosted_zone" {
  name = var.domain_name
  tags = var.labels
}

# Alias record for external load balancer.
# The record that points to the external load balancer
# infront of kubernetes that load balances ingress requests
# between the different kubernetes worker nodes.
# Take all subdomains and make a wildcard pointing to the load balancer.
module "wildcard_dns_alias_record" {
  source = "../../dns-cname-record"

  alias_name     = "*"
  alias_target   = var.load_balancer_alias_dns_name
  domain_name    = var.domain_name
  hosted_zone_id = aws_route53_zone.hosted_zone.zone_id
  labels         = var.labels
  name_prefix    = var.name_prefix
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