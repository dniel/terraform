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


data "aws_iam_policy_document" "AWSLambdaTrustPolicy" {
  statement {
    actions    = ["sts:AssumeRole"]
    effect     = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Let the lambda assume the role.
resource "aws_iam_role" "dyndns53_function_role" {
  name = "dyndns53-${var.domain_name}-role"
  assume_role_policy = templatefile("${path.module}/templates/lambda-base-policy.tpl", {})
}

# Policy to give access to CloudWatch Logs.
resource "aws_iam_policy" "cloudwatch_policy" {
  name = "dyndns53-${var.domain_name}-cloudwatch-policy"
  policy = templatefile("${path.module}/templates/lambda-cloudwatch-policy.tpl", {})
}

# Policy to give access to a specific route53 zone.
resource "aws_iam_policy" "route53_policy" {
  name = "dyndns53-${var.domain_name}-route53-policy"
  policy = templatefile("${path.module}/templates/lambda-route53-policy.tpl", {
    "hosted_zone" = aws_route53_zone.hosted_zone.id
  })
}

# attach cloudwatch policy to role
resource "aws_iam_policy_attachment" "dyndns53_cloudwatch_access" {
  name = "dyndns53-${var.domain_name}-cloudwatch-access"
  roles      = [aws_iam_role.dyndns53_function_role.name]
  policy_arn = aws_iam_policy.cloudwatch_policy.arn
}

# attach route53 policy to role
resource "aws_iam_policy_attachment" "dyndns53_route53_access" {
  name = "dyndns53-${var.domain_name}-route53-access"
  roles      = [aws_iam_role.dyndns53_function_role.name]
  policy_arn = aws_iam_policy.route53_policy.arn
}

## create lambda to update dynamic dns.

data "archive_file" "dyndns_route53_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda_function_dyndns53.py"
  output_path = "${path.module}/lambda_function_dyndns53.zip"
}

resource "aws_lambda_function" "dyndns_route53_lambda" {
  filename      = "${path.module}/lambda_function_dyndns53.zip"
  function_name = "dyndns53-${replace(var.domain_name,".","-")}"
  role          = aws_iam_role.dyndns53_function_role.arn
  handler       = "lambda_function.lambda_handler"
  timeout          = 10
  source_code_hash = data.archive_file.dyndns_route53_lambda_zip.output_base64sha256
  runtime = "python2.7"

  environment {
    variables = {
      HASH             = base64sha256(file("${path.module}/lambda/lambda_function_dyndns53.py"))
    }
  }

  lifecycle {
    ignore_changes = [source_code_hash]
  }
}