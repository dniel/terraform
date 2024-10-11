# just a comment
terraform {
  required_providers {
    k8s = {
      source = "banzaicloud/k8s"
      version = "0.9.1"
    }
    aws = {
      source = "hashicorp/aws"
      version = "3.75.1"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.5.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.33.0"
    }
    kubernetes-alpha = {
      source = "hashicorp/kubernetes-alpha"
      version = "0.5.0"
    }
    auth0 = {
      source = "alexkappa/auth0"
      version = "0.21"
    }
  }
  required_version = "1.0.0"
}
