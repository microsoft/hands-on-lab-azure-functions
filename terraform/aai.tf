resource "azurerm_application_insights" "this" {
  name                = format("appi-%s", local.resource_suffix_kebabcase)
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = "web"
}
