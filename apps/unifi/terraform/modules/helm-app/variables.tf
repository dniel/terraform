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
  default = ""
  type = string
}

variable "values" {
  type        = list(object({ name = string, value = string }))
  default     = []
  description = "Custom set of values to set on helm chart"
}

variable "labels" {
  default     = {}
  type        = map(string)
  description = "Labels to add to resources created"
}
