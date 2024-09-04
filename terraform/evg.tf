resource "azurerm_eventgrid_system_topic" "audio_files" {
  name                   = format("evgt-audio-%s", local.resource_suffix_kebabcase)
  resource_group_name    = azurerm_resource_group.this.name
  location               = azurerm_resource_group.this.location
  source_arm_resource_id = azurerm_storage_account.this.id
  topic_type             = "Microsoft.Storage.StorageAccounts"
  tags                   = local.tags
}