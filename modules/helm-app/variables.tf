variable "name_prefix" {
}

variable "domain_name" {
}

variable "name" {
}

variable "repository" {
}

variable "chart" {
}

variable "chart_version" {
}

variable "values" {
  type        = list(object({ name = string, value = string }))
  default     = []
  description = "Custom set of values to set on helm chart"
}

variable "labels" {
  type = map
  default = {}
  description = "Labels to add to dns record."
}
