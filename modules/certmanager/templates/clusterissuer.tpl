#################################
# ClusterIssuer.
apiVersion: cert-manager.io/v1alpha3
kind: ClusterIssuer
metadata:
  name: letsencrypt-${name_prefix}-issuer
spec:
  acme:
    email: daniel@engfeldt.net
    privateKeySecretRef:
      name: letsencrypt-dns01-prod
    server: https://acme-v02.api.letsencrypt.org/directory
    solvers:
    - dns01:
        route53:
          accessKeyID: ${accesskey}
          hostedZoneID: ${hosted_zone_id}
          region: eu-central-1
          role: ""
          secretAccessKeySecretRef:
            key: AWS_SECRET_KEY
            name: ${name_prefix}-route53-creds
      selector:
        dnsZones:
        - ${domain_name}