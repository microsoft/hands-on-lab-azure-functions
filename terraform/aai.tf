resource "azurerm_application_insights" "func_std" {
  name                          = format("appi-std-%s", local.resource_suffix_kebabcase)
  location                      = azurerm_resource_group.this.location
  resource_group_name           = azurerm_resource_group.this.name
  workspace_id                  = azurerm_log_analytics_workspace.this.id
  application_type              = "web"
  local_authentication_disabled = true
  tags                          = local.tags
}

resource "azurerm_application_insights" "func_drbl" {
  name                          = format("appi-drbl-%s", local.resource_suffix_kebabcase)
  location                      = azurerm_resource_group.this.location
  resource_group_name           = azurerm_resource_group.this.name
  workspace_id                  = azurerm_log_analytics_workspace.this.id
  application_type              = "web"
  local_authentication_disabled = true
  tags                          = local.tags
}
