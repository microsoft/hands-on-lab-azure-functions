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
  default     = "eastus2"
}

variable "owner" {
  description = "The name of the project's owner"
  type        = string
  default     = "ms"
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

variable "user_id" {
  description = "The user id to assign the Contributor role to the resource group"
  type        = string
  default     = ""
}
