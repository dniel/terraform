terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.45.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.2.0"
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
  required_version = "1.0.0"

  backend "s3" {
    bucket     = "198596758466-terraform-state"
    key        = "prod/terraform.tfstate"
    region     = "eu-north-1"
    encrypt    = "true"
    kms_key_id = "arn:aws:kms:eu-north-1:198596758466:alias/terraform-state"
  }
}
