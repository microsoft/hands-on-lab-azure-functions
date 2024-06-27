resource "azurerm_role_assignment" "this" {
  count                = var.user_id != "" ? 1 : 0
  scope                = azurerm_resource_group.this.id
  role_definition_name = "Contributor"
  principal_id         = var.user_id
}

resource "azurerm_role_assignment" "website_contributor_standard_function" {
  count                = var.create_managed_identity ? 1 : 0
  scope                = azurerm_linux_function_app.standard.id
  role_definition_name = "Website Contributor"
  principal_id         = azurerm_user_assigned_identity.standard_function[0].principal_id
}
