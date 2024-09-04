resource "azurerm_cognitive_account" "speech_to_text" {
  name                = format("cog-%s", local.resource_suffix_kebabcase)
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  kind                = "SpeechServices"
  sku_name = "S0"
  tags = local.tags

  identity {
    type = "SystemAssigned"
  }
}
