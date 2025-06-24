resource "azapi_resource" "plan_func_std" {
  type                      = "Microsoft.Web/serverfarms@2023-12-01"
  name                      = format("asp-std-%s", local.resource_suffix_kebabcase)
  location                  = azurerm_resource_group.this.location
  parent_id                 = azurerm_resource_group.this.id
  schema_validation_enabled = false
  body = {
    kind = "functionapp",
    sku = {
      tier = "FlexConsumption",
      name = "FC1"
    },
    properties = {
      reserved = true
    }
  }
  tags = local.tags_azapi
}

resource "azapi_resource" "plan_func_drbl" {
  type                      = "Microsoft.Web/serverfarms@2023-12-01"
  name                      = format("asp-drbl-%s", local.resource_suffix_kebabcase)
  location                  = azurerm_resource_group.this.location
  parent_id                 = azurerm_resource_group.this.id
  schema_validation_enabled = false
  body = {
    kind = "functionapp",
    sku = {
      tier = "FlexConsumption",
      name = "FC1"
    },
    properties = {
      reserved = true
    }
  }
  tags = local.tags_azapi
}