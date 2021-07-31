#############################################
# Install Minecraft Java edition.
# bump
#############################################
module "minecraft" {
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
      name  = "minecraftServer.cpu"
      value = "2000m"
    },
    {
      name  = "minecraftServer.memory"
      value = "4096"
    },
    {
      name = "resources.requests.memory"
      value = "4Gi"
    },
    {
      name  = "minecraftServer.motd"
      value = "Welcome to RoboMemin64s Burning Hellscape"
    },
    {
      name  = "minecraftServer.version"
      value = "1.16.5"
    },
    {
      name  = "minecraftServer.eula"
      value = "true"
    },
    {
      name  = "minecraftServer.type"
      value = "CURSEFORGE"
    },
#    {
#      name  = "minecraftServer.ftbServerMod"
#      value = "https://www.curseforge.com/minecraft/modpacks/skyfactory-4/download/3012800/file"
#    },
    {
      name  = "minecraftServer.cfServerMod"
      value = "https://198596758466-minecraft-modpacks.s3.eu-north-1.amazonaws.com/Better%2BMinecraft%2BServer%2BPack%2B%5BFORGE%5D%2Bv30%2Bhf.zip"
#      value = "https://198596758466-minecraft-modpacks.s3.eu-north-1.amazonaws.com/SkyFactory-4_Server_4.2.2.zip"
    },
    {
      name  = "minecraftServer.forceReDownload"
      value = "TRUE"
    },    
    {
      name  = "minecraftServer.forgeVersion"
      value = "36.1.32"
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

