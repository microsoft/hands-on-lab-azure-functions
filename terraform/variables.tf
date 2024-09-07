variable "environment" {
  description = "The environment deployed"
  type        = string
  default     = "lab"
  validation {
    condition     = can(regex("(lab|dev|stg|prd)", var.environment))
    error_message = "The environment value must be a valid."
  }
}

variable "application" {
  default     = "hol"
  description = "Name of the application"
  type        = string
}

variable "location" {
  description = "Azure deployment location"
  type        = string
  default     = "swedencentral"
}

variable "resource_group_name_suffix" {
  type        = string
  default     = "01"
  description = "The resource group name suffix"
}

variable "tags" {
  type        = map(any)
  description = "The custom tags for all resources"
  default     = {}
}