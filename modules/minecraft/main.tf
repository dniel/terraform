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
      name  = "minecraftServer.forgeVersion"
      value = "36.1.32"
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