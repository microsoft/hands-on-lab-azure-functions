# resource "azurerm_api_management" "this" {
#   name                = format("apim-%s", local.resource_suffix_kebabcase)
#   location            = azurerm_resource_group.this.location
#   resource_group_name = azurerm_resource_group.this.name
#   publisher_name      = "Hands On Lab Company"
#   publisher_email     = "company@hol.io"

#   sku_name = "Consumption_0"
#   tags     = local.tags

#   identity {
#     type = "SystemAssigned"
#   }
# }
