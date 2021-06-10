terraform {
  required_providers {
    k8s = {
      source = "banzaicloud/k8s"
      version = "0.9.1"
    }
    aws = {
      source = "hashicorp/aws"
      version = "3.44.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.1.2"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.3.2"
    }
    kubernetes-alpha = {
      source = "hashicorp/kubernetes-alpha"
      version = "0.5.0"
    }
    auth0 = {
      source = "terraform-providers/auth0"
      version = "0.14"
    }
  }
  required_version = "0.14.9"

  backend "s3" {
    bucket     = "198596758466-terraform-state"
    key        = "home-services/terraform.tfstate"
    region     = "eu-north-1"
    acl        = "bucket-owner-full-control"
    encrypt    = "true"
    kms_key_id = "arn:aws:kms:eu-north-1:198596758466:alias/terraform-state"
  }
}
