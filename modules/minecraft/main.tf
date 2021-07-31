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
  chart_version = "3.2.0"

  values = [
    {
      name  = "imageTag"
      value = "java8"
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
      value = "FORGE"
    },
    {
      name  = "minecraftServer.motd"
      value = "Welcome to RoboMemin64s Burning Hellscape"
    },
    {
      name  = "minecraftServer.downloadModpackUrl"
      value = "https://198596758466-minecraft-modpacks.s3.eu-north-1.amazonaws.com/Better%2BMinecraft%2BServer%2BPack%2B%5BFORGE%5D%2Bv26.zip"
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
    }
# Add persistence annotations for directory permissions
#    {
#      name  = "persistence.annotations"
#      value = ""
#    }
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

