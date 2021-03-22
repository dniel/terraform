terraform {
  required_providers {
    k8s = {
      source = "banzaicloud/k8s"
    }
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
      version = "0.2.1"
    }
    auth0 = {
      source = "terraform-providers/auth0"
    }
  }
  required_version = "0.14"

  backend "s3" {
    bucket     = "198596758466-terraform-state"
    key        = "home-services/terraform.tfstate"
    region     = "eu-north-1"
    acl        = "bucket-owner-full-control"
    encrypt    = "true"
    kms_key_id = "arn:aws:kms:eu-north-1:198596758466:alias/terraform-state"
  }
}
