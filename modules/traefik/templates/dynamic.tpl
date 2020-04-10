http:
  middlewares:
    api-stripprefix:
      stripPrefix:
        prefixes:
          - "/api"
    forwardauth:
      forwardAuth:
        address: http://forwardauth.forwardauth/authorize
        trustForwardHeader: true
        authResponseHeaders:
          - authorization
          - x-forwardauth-nickname
          - x-forwardauth-family-name
          - x-forwardauth-given-name
          - x-forwardauth-name
          - x-forwardauth-sub
          - x-forwardauth-email

tls:
  stores:
    default:
      defaultCertificate:
        certFile: /ssl/tls.crt
        keyFile: /ssl/tls.key
  certificates:
    - certFile: /ssl/tls.crt
      keyFile: /ssl/tls.key

