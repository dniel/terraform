#####################################
# Create a Alias record in DNS.
#
#####################################
resource "aws_route53_record" "dns_alias_record" {
  zone_id = var.hosted_zone_id
  name    = var.alias_name
  type    = "CNAME"

  ttl     = "120"
  records = [var.alias_target]
}
