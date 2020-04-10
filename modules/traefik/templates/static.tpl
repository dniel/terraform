log:
  level: DEBUG

global:
  checkNewVersion: true
  sendAnonymousUsage: false

serversTransport:
  insecureSkipVerify: true

entryPoints:
  web:
    address: :8000

  websecure:
    address: :8443

  traefik:
    address: :9000

ping: {}
api: {}

providers:
  kubernetesIngress: {
    ingressClass: "traefik-${name_prefix}"
  }
  kubernetesCRD: {
    ingressClass: "traefik-${name_prefix}"
  }
  file:
    filename: /config/dynamic.yml