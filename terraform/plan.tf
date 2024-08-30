resource "azapi_resource" "server_farm" {
  type                      = "Microsoft.Web/serverfarms@2023-12-01"
  name                      = format("asp-%s", local.resource_suffix_kebabcase)
  location                  = azurerm_resource_group.this.location
  parent_id                 = azurerm_resource_group.this.id
  schema_validation_enabled = false
  body = jsonencode({
    kind = "functionapp",
    sku = {
      tier = "FlexConsumption",
      name = "FC1"
    },
    properties = {
      reserved = true
    }
  })
  tags = local.tags
}
