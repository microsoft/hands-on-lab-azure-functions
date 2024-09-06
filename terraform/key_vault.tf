resource "azurerm_key_vault" "this" {
  name                        = format("kv-%s", local.resource_suffix_kebabcase)
  location                    = azurerm_resource_group.this.location
  resource_group_name         = azurerm_resource_group.this.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false # For demo purposes only

  sku_name = "standard"
}

resource "azurerm_key_vault_access_policy" "azurerm_client_config" {
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Get",
    "Delete",
    "Purge",
    "Recover"
  ]
}

resource "azurerm_key_vault_access_policy" "func_drbl" {
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_linux_function_app.func_drbl.identity[0].principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

resource "azurerm_key_vault_secret" "speech_to_text_api_key" {
  name         = "speechToTextApiKey"
  value        = azurerm_cognitive_account.speech_to_text.primary_access_key
  key_vault_id = azurerm_key_vault.this.id

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}
