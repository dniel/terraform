terraform {
  required_providers {
    auth0 = {
      source = "terraform-providers/auth0"
    }
    helm = {
      source = "hashicorp/helm"
    }
  }
  required_version = "0.14.9"
}
