## Create a Function App

```sh
az functionapp create \
    --name <function-app-name> \
    --consumption-plan-location <region> \
    --resource-group <resource-group> \
    --runtime dotnet-isolated \
    --os-type Linux \
    --functions-version 4 \
    --runtime-version 8 \
    --storage-account <storage-account>
```

## Create the AudioUpload function

```sh
func init --worker-runtime dotnet-isolated --target-framework net8.0
func new --name AudioUpload --template "HTTP trigger" --authlevel "function"
dotnet add package Microsoft.Azure.Functions.Worker.Extensions.Storage.Blobs --version 6.3.0
```

## Publishing the Function App

```sh
func azure functionapp publish <function-app-name>
```
