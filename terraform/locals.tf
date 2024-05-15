locals {
  resource_suffix           = [lower(var.environment), substr(lower(var.location), 0, 2), substr(lower(var.application), 0, 3), lower(var.owner), random_id.resource_group_name_suffix.hex, var.resource_group_name_suffix]
  resource_suffix_kebabcase = join("-", local.resource_suffix)
  resource_suffix_lowercase = join("", local.resource_suffix)

  storage_account_container_name = "audios"

  cosmos_db_database_name  = "HolDb"
  cosmos_db_container_name = "audios_transcripts"

  tags = merge(
    var.tags,
    tomap(
      {
        "Deployment"      = "terraform",
        "Environment"     = var.environment,
        "Location"        = var.location,
        "ProjectName"     = "hands-on-lab-functions",
        "Application"     = var.application
        "Resource Suffix" = var.resource_group_name_suffix
      }
    )
  )
}
