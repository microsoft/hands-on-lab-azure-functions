resource "azurerm_key_vault" "this" {
  name                        = format("kv-%s", local.resource_suffix_kebabcase)
  location                    = azurerm_resource_group.this.location
  resource_group_name         = azurerm_resource_group.this.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false # For demo purposes only
  enable_rbac_authorization   = true
  tags                        = local.tags

  sku_name = "standard"
}

resource "azurerm_key_vault_secret" "speech_to_text_api_key" {
  name         = "speechToTextApiKey"
  value        = azurerm_cognitive_account.speech_to_text.primary_access_key
  key_vault_id = azurerm_key_vault.this.id
  tags         = local.tags

  lifecycle {
    ignore_changes = [
      value
    ]
  }

  depends_on = [
    azurerm_role_assignment.user_key_vault_administrator
  ]
}
