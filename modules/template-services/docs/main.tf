######################################################
#
######################################################
locals {
  labels = merge(var.labels, {
  })
  forwardauth_middleware_namespace = var.name_prefix
  forwardauth_middleware_name      = "forwardauth-authorize"
}

# Bucket to upload docs to.
# TODO: need to define a s3 bucket policy
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy
resource "aws_s3_bucket" "docs_bucket" {
  bucket = "198596758466-docs"
}

# TODO add ingress route for docs pointing to S3 bucket.