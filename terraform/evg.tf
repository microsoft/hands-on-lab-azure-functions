resource "azurerm_eventgrid_system_topic" "audio_files" {
  name                   = format("evg-%s", local.resource_suffix_kebabcase)
  resource_group_name    = azurerm_resource_group.this.name
  location               = azurerm_resource_group.this.location
  source_arm_resource_id = azurerm_storage_account.this.id
  topic_type             = "Microsoft.Storage.StorageAccounts"
}

data "azurerm_function_app_host_keys" "func_drbl" {
  name                = data.azurerm_linux_function_app.func_drbl_wrapper.name
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_eventgrid_system_topic_event_subscription" "new_audio_file" {
  name                = format("evgs-audio-%s", local.resource_suffix_kebabcase)
  system_topic        = azurerm_eventgrid_system_topic.audio_files.name
  resource_group_name = azurerm_resource_group.this.name
  included_event_types = [
    "Microsoft.Storage.BlobCreated"
  ]

  webhook_endpoint {
    url = "https://${data.azurerm_linux_function_app.func_drbl_wrapper.default_hostname}/runtime/webhooks/blobs?functionName=Host.Functions.AudioBlobUploadStart&code=${data.azurerm_function_app_host_keys.func_drbl.blobs_extension_key}"
  }
}
