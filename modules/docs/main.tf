######################################################
# Docs
######################################################
# Create the Docs storage bucket where docs are stored as
# static websites and accessed through Traefik.
resource "aws_s3_bucket" "docs_bucket" {
  bucket = "198596758466-docs"
  acl    = "public-read"
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

# Create K8s Service with Externalname to use for ingressroutes.
resource "kubernetes_manifest" "docs-external-website-service" {
  provider   = kubernetes-alpha

  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Service"
    "metadata" = {
      "namespace" = var.name_prefix
      "name"      = "docs-external-website"
    }
    "spec" = {
      "externalName" = aws_s3_bucket.docs_bucket.website_endpoint
      "type" = "ExternalName"
      "ports" = [
        {
          "port" = 80
          "protocol" = "TCP"
        }
      ]
    }
  }
}