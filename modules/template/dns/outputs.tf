output "hosted_zone_id" {
  value       = aws_route53_zone.hosted_zone.id
  description = "The ID of the hosted zone where dns record was created."
}