terraform {
  required_providers {
    uptimerobot = {
      source  = "louy/uptimerobot"
      version = "0.5.1"
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
    }
    auth0 = {
      source = "terraform-providers/auth0"
    }
  }
  required_version = "0.15.0-beta2"

  backend "s3" {
    bucket     = "198596758466-terraform-state"
    key        = "unifi/stable.tfstate"
    region     = "eu-north-1"
    encrypt    = "true"
    kms_key_id = "arn:aws:kms:eu-north-1:198596758466:alias/terraform-state"
  }
}