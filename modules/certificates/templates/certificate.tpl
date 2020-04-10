apiVersion: cert-manager.io/v1alpha3
kind: Certificate
metadata:
  name: ${name}
  labels:
    app: ${app_name}
    env: ${name_prefix}
spec:
  secretName: ${secretName}
  renewBefore: 360h # 15d
  commonName: '${dnsName}'
  dnsNames:
  - '${dnsName}'
  issuerRef:
    name: letsencrypt-${name_prefix}-issuer
    kind: ClusterIssuer
