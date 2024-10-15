# The managed identity to be used to deploy the Azure Function App using GitHub Actions.
resource "azurerm_user_assigned_identity" "func_std" {
  location            = azurerm_resource_group.this.location
  name                = format("id-func-std-%s", local.resource_suffix_kebabcase)
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
}