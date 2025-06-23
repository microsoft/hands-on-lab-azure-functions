locals {
  resource_suffix           = [lower(var.environment), substr(lower(var.location), 0, 2), substr(lower(var.application), 0, 3), random_id.resource_group_name_suffix.hex]
  resource_suffix_kebabcase = join("-", local.resource_suffix)
  resource_suffix_lowercase = join("", local.resource_suffix)

  open_ai_config_name = format("oai-%s", local.resource_suffix_kebabcase)

  storage_account_container_name = "audios"

  cosmos_db_database_name  = "HolDb"
  cosmos_db_container_name = "audios_transcripts"

  function_deployment_package_container = "deploymentpackage"

  func_drbl_name = format("func-drbl-%s", local.resource_suffix_kebabcase)
  func_std_name  = format("func-std-%s", local.resource_suffix_kebabcase)

  tags = merge(
    var.tags,
    tomap(
      {
        "Deployment"  = "terraform",
        "Environment" = var.environment,
        "Location"    = var.location,
        "ProjectName" = "hands-on-lab-azure-functions",
        "Application" = var.application
      }
    )
  )

  tags_azapi = merge(
    local.tags,
    tomap(
      {
        "TypeOfDeployment" = "azapi"
      }
    )
  )
}
