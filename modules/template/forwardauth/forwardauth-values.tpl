replicaCount: 1

image:
  repository: index.docker.io/dniel/forwardauth
  tag: 2.0-rc1.spa.support
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
default: {
}

# Access ForwardAuth in two different configuration modes.
mode:
  host: true
  path: true

service:
  type: ClusterIP
  port: 80

# Traefik2 CRD IngressRoute configuration
ingressroute:
  enabled: true
  hostname: auth.${domain_name}
  path: /auth
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
    login-uri: https://spademo.${domain_name}
    logout-uri: https://spademo.${domain_name}/logout
    claims:
    - sub
    - name
    - email

  apps:
  - name: traefik.${domain_name}
  - name: whoami.${domain_name}
  - name: spin.${domain_name}

resources:
  limits:
    memory: 512Mi
  requests:
    memory: 512Mi

nodeSelector: {}

tolerations: []

affinity: {}
