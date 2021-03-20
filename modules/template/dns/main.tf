resource "aws_route53_zone" "hosted_zone" {
  name = var.domain_name
  tags = var.labels
}

# Alias record for external load balancer.
# The record that points to the external load balancer
# in front of kubernetes that load balances ingress requests
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
resource "aws_route53_record" "nested_domain_ns" {
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

## create lambda to update dynamic dns.
//resource "aws_iam_role" "iam_for_lambda" {
//  name = "iam_for_dyndns53_${var.name_prefix}_lambda"
//  assume_role_policy = <<EOF
//{
//  "Version": "2012-10-17",
//  "Statement": [{
//      "Effect": "Allow",
//      "Action": [
//          "route53:ChangeResourceRecordSets"
//      ],
//      "Resource": "arn:aws:route53:::hostedzone/${aws_route53_zone.hosted_zone.id}"
//  }, {
//      "Effect": "Allow",
//      "Action": [
//          "route53:ListResourceRecordSets"
//      ],
//      "Resource": "arn:aws:route53:::hostedzone/${aws_route53_zone.hosted_zone.id}"
//  }, {
//      "Effect": "Allow",
//      "Action": [
//          "route53:GetChange"
//      ],
//      "Resource": "arn:aws:route53:::change/*"
//  }, {
//      "Effect": "Allow",
//      "Action": [
//          "logs:CreateLogGroup",
//          "logs:CreateLogStream",
//          "logs:PutLogEvents"
//      ],
//      "Resource": "arn:aws:logs:*:*:*"
//  }]
//}
//EOF
//}
//
//data "archive_file" "dyndns_route53_lambda_zip" {
//  type        = "zip"
//  source_file = "${path.module}/lambda/lambda_function_dyndns53.py"
//  output_path = "${path.module}/lambda_function_dyndns53.zip"
//}
//
//resource "aws_lambda_function" "dyndns_route53_lambda" {
//  filename      = "lambda_function_dyndns53.zip"
//  function_name = "dyndns53-${var.name_prefix}"
//  role          = aws_iam_role.iam_for_lambda.arn
//  handler       = "lambda_function.lambda_handler"
//  timeout          = 10
//  source_code_hash = data.archive_file.dyndns_route53_lambda_zip.output_base64sha256
//  runtime = "python2.7"
//
//  environment {
//    variables = {
//      HASH             = base64sha256(file("${path.module}/lambda/lambda_function_dyndns53.py"))
//    }
//  }
//
//  lifecycle {
//    ignore_changes = [source_code_hash]
//  }
//}