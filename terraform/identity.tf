resource "azurerm_user_assigned_identity" "standard_function" {
  count               = var.create_managed_identity ? 1 : 0
  location            = azurerm_resource_group.this.location
  name                = format("id-func-std-%s", local.resource_suffix_kebabcase)
  resource_group_name = azurerm_resource_group.this.name
}