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
      name  = "minecraftServer.eula"
      value = "true"
    },
    {
      name  = "minecraftServer.type"
      value = "FORGE"
    },
    {
      name  = "minecraftServer.forgeVersion"
      value = "36.1.123124"
    },
    {
      name  = "securityContext.runAsUser"
      value = "0"
    },
    {
      name  = "securityContext.fsGroup"
      value = "0"
    }
  ]
}
