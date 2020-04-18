replicaCount: 1

image:
  repository: index.docker.io/dniel/forwardauth
#  tag: latest
  pullPolicy: Always

# set logLevel to DEBUG, TEST, or PRODUCTION to control the verbosity of logs
# the container by default logs to STDOUT
logLevel: DEBUG

# Base configuration for OAuth2 and OIDC properties.
# domain, token endpoin, authorize url that needs to be set
# to enable the OAuth2 and oidc authentication workflows.
# If they are set here, they are injected as environment properties
# on the container instead of read from application.yaml
# It is also possible to set in application.yaml below.
domain: https://${tenant}/
tokenEndpoint: https://${tenant}/oauth/token
authorizeUrl: https://${tenant}/authorize

# set the default application client-id and client-secret
# as environmentvariables to container and inject values from
# secrets instead of from application.yaml
default: {}

# Access ForwardAuth in two different configuration modes.
mode:
  host: true
  path: false

service:
  type: ClusterIP
  port: 80

# Traefik2 CRD IngressRoute configuration
ingressroute:
  enabled: true
  hostname: auth.${domain_name}
  path: /oauth2
  certResolver: default

# Standard kubernetes Ingress configuration
ingress:
  enabled: false

# Application config file that are stored as configmap and
# mounted by the container/pod.
applicationYaml:
  domain: https://${tenant}/
  token-endpoint: https://${tenant}/oauth/token
  authorize-url: https://${tenant}/authorize
  userinfo-endpoint: https://${tenant}/userinfo
  logout-endpoint:  https://${tenant}/v2/logout

  default:
    name: default
    scope: "profile openid email"
    redirect-uri: https://auth.${domain_name}/signin
    claims:
    - sub
    - name
    - email

  apps:
  - name: traefik.${domain_name}
    required-permissions:
    - read:traefik
  - name: whoami.${domain_name}
    required-permissions:
    - read:whoami
  - name: www.${domain_name}
    required-permissions:
    - read:www
    restricted-methods:
    - POST
    - PUT
    - PATCH
    - DELETE
  - name: spin.${domain_name}
    required-permissions:
    - read:spinnaker
  - name: ubnt.${domain_name}
    required-permissions:
    - read:unifi
  - name: api-graphql.${domain_name}
    required-permissions:
    - read:graphql
  - name: api-posts.${domain_name}
    required-permissions:
    - read:posts

resources:
  limits:
    memory: 512Mi
  requests:
    memory: 512Mi

nodeSelector: {}

tolerations: []

affinity: {}
