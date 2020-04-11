##################################
#
#
##################################
module "traefik" {
  source      = "../traefik"
  domain_name = var.domain_name
  name_prefix = var.name_prefix
  labels      = var.labels

  traefik_helm_release_version = var.traefik_helm_release_version
  traefik_websecure_port       = var.traefik_websecure_port
  traefik_service_type         = var.traefik_service_type
}

##################################
#
#
##################################
module "forwardauth" {
  source      = "../forwardauth"
  domain_name = var.domain_name
  name_prefix = var.name_prefix
  labels      = var.labels

  forwardauth_audience             = var.forwardauth_audience
  forwardauth_clientid             = var.forwardauth_clientid
  forwardauth_clientsecret         = var.forwardauth_clientsecret
  forwardauth_token_cookie_domain  = var.forwardauth_token_cookie_domain
  forwardauth_helm_release_version = var.forwardauth_helm_release_version
}

##################################
#
#
##################################
module "dns" {
  source      = "../dns"
  domain_name = var.domain_name
  name_prefix = var.name_prefix
  labels      = var.labels

  dns_names = concat(var.dns_names,
    [
      module.traefik.dns_name,
      module.forwardauth.dns_name
    ]
  )

  load_balancer_public_ip      = var.load_balancer_public_ip
  load_balancer_alias_dns_name = var.load_balancer_alias_dns_name
  load_balancer_alias_hosted_zone_id = var.load_balancer_alias_hosted_zone_id

  # the primary hosted zone if the new zone if a nested zone.
  primary_hosted_zone_id = var.primary_hosted_zone_id
}

##################################
#
#
##################################
module "certificates" {
  source      = "../certificates"
  domain_name = var.domain_name
  name_prefix = var.name_prefix
  labels      = var.labels

  aws_access_key = var.certificates_aws_access_key
  aws_secret_key = var.certificates_aws_secret_key
  hosted_zone_id = module.dns.hosted_zone_id

  certificates = {
    # wildcard certificate for environament, like *.example.com
    # used by traefik to serve all websites with a wildcard certificate.
    traefik-default = {
      secretName = var.traefik_default_tls_secretName
      namespace  = module.traefik.namespace
      dnsName    = "*.${var.domain_name}"
    }
  }
}