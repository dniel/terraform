variable "certificates_aws_access_key" {
  type = string
}

variable "certificates_aws_secret_key" {
  type = string
}

variable "auth0_domain" {}
variable "auth0_client_id" {}
variable "auth0_client_secret" {}

# If set register the Traefik instance at pilot.traefik.io
variable "traefik_pilot_token" {
  type    = string
  default = ""
}
