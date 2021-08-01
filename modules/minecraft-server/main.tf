#############################################
# Install Minecraft Java edition.
# bump
#############################################
module "minecraft-server" {
  source      = "github.com/dniel/terraform?ref=master/modules/helm-app"
  name_prefix = var.name_prefix
  domain_name = var.domain_name

  repository = "https://itzg.github.io/minecraft-server-charts"

  name          = "minecraft"
  chart         = "minecraft"
  chart_version = "3.4.2"

  values = [
    {
      name = "extraEnv.DEBUG"
      value = "TRUE"
    },
    {
      name  = "imageTag"
      value = "java8"
    },
    {
      name  = "startupProbe.enabled"
      value = "true"
    },
    {
      name  = "startupProbe.failureThreshold"
      value = "60"
    {
      name  = "minecraftServer.memory"
      value = var.memory
    },
    {
      name  = "resources.requests.cpu"
      value = var.cpu
    },
    {
      name = "resources.requests.memory"
      value = "${var.memory}Mi"
    },
    {
      name  = "minecraftServer.motd"
      value = var.motd
    },
    {
      name  = "minecraftServer.version"
      value = var.version
    },
    {
      name  = "minecraftServer.eula"
      value = "true"
    },
    {
      name  = "minecraftServer.type"
      value = var.type
    },
    {
      name  = "minecraftServer.cfServerMod"
      value = var.modpack_url
    },
    {
      name  = "minecraftServer.ftbServerMod"
      value = var.modpack_url
    },
    {
      name  = "minecraftServer.forceReDownload"
      value = "TRUE"
    },    
    {
      name  = "minecraftServer.removeOldMods"
      value = "TRUE"
    },    
    {
      name  = "securityContext.runAsUser"
      value = "0"
    },
    {
      name  = "securityContext.fsGroup"
      value = "0"
    },
    {
      name  = "persistence.dataDir.enabled"
      value = "true"
    },
    {
      name  = "persistence.dataDir.Size"
      value = "2Gi"
    }
  ]
}

# Expose minecraft server on Traefik.
resource "kubernetes_manifest" "ingressroute_minecraft" {
  provider = kubernetes-alpha

  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRouteTCP"
    "metadata" = {
      "annotations" = {
        "kubernetes.io/ingress.class" = "traefik-${var.name_prefix}"
      },
      "namespace" = var.name_prefix
      "name"      = "mc"
    }
    "spec" = {
      "entryPoints" = [
        "minecraft",
      ]
      "routes" = [
        {
          "match" = "HostSNI(`*`)",
          "services" = [
            {
              "name" = "minecraft-minecraft"
              "port" = 25565
            }
          ]
        },
      ]
    }
  }
}

