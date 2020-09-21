terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    kubernetes-alpha = {
      source = "hashicorp/kubernetes-alpha"
    }
    auth0 = {
      source = "terraform-providers/auth0"
    }
  }
  required_version = ">= 0.13"
}
