## Update the App settings to use system-assigned managed identity

Follow this [guide](https://learn.microsoft.com/en-us/azure/azure-functions/functions-reference?tabs=blob&pivots=programming-language-csharp#configure-an-identity-based-connection) to setup a system-assigned managed identity, grant it Write access to the Audio file storage account, and update the App Settings of the AudioUpload function.

### Steps

1. Assign a system-assigned managed identity to the Function App and grant it the `Storage Blob Data Owner` role on the storage account
1. Deploy the change to the AudioUpload function, namely the new value of `Connection` on the `BlobOutput` binding
1. Add a new environment variable called `AudioUploadStorage__serviceUri` and set its value to the url of the storage account (`https://MY_STORAGE_ACCOUNT.blob.core.windows.net`)
1. Remove the old environment variable `STORAGE_ACCOUNT_CONNECTION_STRING`
1. Apply the changes and ensure you can upload audio files to the blob storage
