resource "azurerm_cognitive_account" "open_ai" {
  name                  = local.open_ai_config_name
  location              = azurerm_resource_group.this.location
  resource_group_name   = azurerm_resource_group.this.name
  kind                  = "OpenAI"
  sku_name              = "S0"
  tags                  = local.tags
  custom_subdomain_name = local.open_ai_config_name

  identity {
    type = "SystemAssigned"
  }
}

# resource "azurerm_cognitive_deployment" "gpt_35_turbo" {
#   name                 = "gpt-35-turbo"
#   cognitive_account_id = azurerm_cognitive_account.open_ai.id
#   model {
#     format  = "OpenAI"
#     name    = "gpt-35-turbo"
#     version = "1106"
#   }

#   sku {
#     name     = "GlobalStandard"
#     capacity = 10
#   }
# }
