variable "name_prefix" {
}

variable "domain_name" {
}

variable "" {
  description = "The image tag for the minecraft container to use"
  default     = "latest"
}

variable "server_version" {
  description = "Minecraft server version"
}

variable "server_type" {
  default     = "VANILLA"
  description = "Minecraft server type (vanilla, curseforge ++)"
}

variable "server_mode" {
  default     = "survival"
  description = "Minecraft server mode (survival, creative ++)"
}

variable "server_motd" {
  default     = ""
  description = "(Optional) Message of the day for the server"
}

variable "modpack_url" {
  default     = ""
  description = "(Optional) Url to a zipped CurseForge Server modpack file"
}

variable "world_url" {
  default     = ""
  description = "(Optional) Url to a zipped World file."
}

variable "cpu" {
  default     = "1"
  description = "(Optional) Requested cpu units to the pod"
}

variable "memory" {
  default     = "2048"
  description = "(Optional) Requested memory units in megabytes to the pod."
}
