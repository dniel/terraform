apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  annotations:
    kubernetes.io/ingress.class: traefik-${name_prefix}
  labels:
    app: ${app_name}
    env: ${name_prefix}
  name: traefik-dashboard
spec:
  entryPoints:
  - websecure
  routes:
  - kind: Rule
    match: Host(`traefik.${domain_name}`)
    middlewares:
    - name: ${name_prefix}-forwardauth-forwardauth-authorize@kubernetescrd
      namespace: ${name_prefix}-forwardauth
    services:
    - kind: TraefikService
      name: api@internal
  tls:
    certResolver: default

