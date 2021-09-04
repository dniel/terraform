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

# Create K8s Service with Externalname that points to the S3 bucket
# with the static sites of documentation.
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

# Create the IngressRoute for Traefik to route to the S3 external service above.
resource "kubernetes_manifest" "docs-external-website-service" {
  depends_on = [kubernetes_manifest.middleware_redirect_docs_root]
  provider   = kubernetes-alpha

  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "namespace" = local.name_prefix
      "name"      = "docs-external"
      "annotations" = {
        "kubernetes.io/ingress.class" = "traefik-${local.name_prefix}"
      }
    }
    "spec" = {
      "entryPoints" = ["websecure"]
      "routes" = [
        {
          "kind" = "Rule"
          "match" = "Host(`docs.${var.domain_name}`)"
          "middlewares" = [
            {
              "name"      = "add-docs-sub-path"
              "namespace" = local.name_prefix
            }
          ]
          "services" = [
            {
              "kind" = "Service"
              "name" = "docs-external-website"
              "namespace" = local.name_prefix
              "passHostHeader" = false
              "port" = 80
              "scheme" = "http"
            }
          ]
        }
      ]
      "tls" = {
        "certResolver" = "default"
      }
    }
  }
}

# Middleware that redirects from https://docs.services.nordlab.io to
# https://docs.services.nordlab.io/docs/master for more conventient
# start url of the root documentation site.
resource "kubernetes_manifest" "middleware_redirect_docs_root" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" : "traefik.containo.us/v1alpha1"
    "kind" : "Middleware"
    "metadata" : {
      "namespace" : local.name_prefix
      "name" : "add-docs-sub-path"
    }
    "spec" : {
      "redirectRegex" : {
        "regex" = "^https://docs.${var.domain_name}/?$"
        "replacement" = "https://docs.${var.domain_name}/docs/master"
      }
    }
  }
}
