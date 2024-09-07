resource "azurerm_load_test" "this" {
  location            = azurerm_resource_group.this.location
  name                = format("lt-%s", local.resource_suffix_kebabcase)
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags

  identity {
    type = "SystemAssigned"
  }
}