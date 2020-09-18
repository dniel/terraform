locals {
  forwardauth_middleware_namespace = var.name_prefix
  forwardauth_middleware_name      = "${local.forwardauth_middleware_namespace}-forwardauth-authorize@kubernetescrd"
}

data "helm_repository" "dniel" {
  name = "dniel"
  url  = "https://dniel.github.com/charts"
}

resource "helm_release" "whoami" {
  name       = "whoami"
  repository = data.helm_repository.dniel.id
  chart      = "whoami"
  namespace  = var.namespace.id
  version    = var.whoami_helm_release_version

  dynamic "set" {
    for_each = var.labels
    content {
      name  = "ingressroute.labels.${set.key}"
      value = set.value
    }
  }

  set {
    name  = "ingressroute.enabled"
    value = "true"
  }
  set {
    name  = "ingressroute.annotations.kubernetes\\.io/ingress\\.class"
    value = "traefik-${var.name_prefix}"
  }
  set {
    name  = "ingressroute.hostname"
    value = "whoami.${var.domain_name}"
  }
  set {
    name  = "ingressroute.middlewares[0].name"
    value = local.forwardauth_middleware_name
  }
  set {
    name  = "ingressroute.middlewares[0].namespace"
    value = local.forwardauth_middleware_namespace
  }
}

resource "helm_release" "api-posts" {
  name       = "api-posts"
  repository = data.helm_repository.dniel.id
  chart      = "api-posts"
  namespace  = var.namespace.id
  version    = var.api_posts_helm_release_version

  dynamic "set" {
    for_each = var.labels
    content {
      name  = "ingressroute.labels.${set.key}"
      value = set.value
    }
  }

  set {
    name  = "ingressroute.annotations.kubernetes\\.io/ingress\\.class"
    value = "traefik-${var.name_prefix}"
  }

  set {
    name  = "ingressroute.enabled"
    value = "true"
  }

  set {
    name  = "ingressroute.hostname"
    value = "api-posts.${var.domain_name}"
  }
  set {
    name  = "ingressroute.middlewares[0].name"
    value = local.forwardauth_middleware_name
  }
  set {
    name  = "ingressroute.middlewares[0].namespace"
    value = local.forwardauth_middleware_namespace
  }
}

resource "helm_release" "api-graphql" {
  name       = "api-graphql"
  repository = data.helm_repository.dniel.id
  chart      = "api-graphql"
  namespace  = var.namespace.id
  version    = var.api_graphql_helm_release_version
  dynamic "set" {
    for_each = var.labels
    content {
      name  = "ingressroute.labels.${set.key}"
      value = set.value
    }
  }

  set {
    name  = "ingressroute.annotations.kubernetes\\.io/ingress\\.class"
    value = "traefik-${var.name_prefix}"
  }
  set {
    name  = "ingressroute.enabled"
    value = "true"
  }
  set {
    name  = "ingressroute.hostname"
    value = "api-graphql.${var.domain_name}"
  }
  set {
    name  = "ingressroute.middlewares[0].name"
    value = local.forwardauth_middleware_name
  }
  set {
    name  = "ingressroute.middlewares[0].namespace"
    value = local.forwardauth_middleware_namespace
  }
}

resource "helm_release" "website" {
  name       = "www"
  repository = data.helm_repository.dniel.id
  chart      = "www"
  namespace  = var.namespace.id
  version    = var.website_helm_release_version

  dynamic "set" {
    for_each = var.labels
    content {
      name  = "ingressroute.labels.${set.key}"
      value = set.value
    }
  }

  set {
    name  = "ingressroute.annotations.kubernetes\\.io/ingress\\.class"
    value = "traefik-${var.name_prefix}"
  }
  set {
    name  = "ingressroute.enabled"
    value = "true"
  }
  set {
    name  = "ingressroute.hostname"
    value = "www.${var.domain_name}"
  }
  set {
    name  = "ingressroute.middlewares[0].name"
    value = local.forwardauth_middleware_name
  }
  set {
    name  = "ingressroute.middlewares[0].namespace"
    value = local.forwardauth_middleware_namespace
  }
}

resource "helm_release" "spa-demo" {
  name       = "spa-demo"
  repository = data.helm_repository.dniel.id
  chart      = "spa-demo"
  namespace  = var.namespace.id
  version    = var.spa_demo_helm_release_version

  dynamic "set" {
    for_each = var.labels
    content {
      name  = "ingressroute.labels.${set.key}"
      value = set.value
    }
  }

  set {
    name  = "ingressroute.annotations.kubernetes\\.io/ingress\\.class"
    value = "traefik-${var.name_prefix}"
  }
  set {
    name  = "ingressroute.enabled"
    value = "true"
  }
  set {
    name  = "ingressroute.hostname"
    value = "spa-demo.${var.domain_name}"
  }
  set {
    name  = "ingressroute.middlewares[0].name"
    value = local.forwardauth_middleware_name
  }
  set {
    name  = "ingressroute.middlewares[0].namespace"
    value = local.forwardauth_middleware_namespace
  }
}