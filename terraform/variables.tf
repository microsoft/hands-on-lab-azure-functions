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

variable "tags" {
  type        = map(any)
  description = "The custom tags for all resources"
  default     = {}
}