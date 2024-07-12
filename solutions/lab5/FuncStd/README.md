## Simulating unexpected behaviors

### Create the GetTranscriptions function

```sh
func new --name GetTranscriptions --template "HTTP trigger" --authlevel "function"
dotnet add package Microsoft.Azure.Functions.Worker.Extensions.CosmosDB --version 4.8.0
```

In order to [use RBAC with CosmosDB](https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-cosmosdb-v2-input?tabs=python-v2%2Cisolated-process%2Cnodejs-v4%2Cextensionv4&pivots=programming-language-csharp#identity-based-connections), you will also need to:
1. Assign the Function App a system-assigned managed identity (this should have already been done in a previous lab)
1. Grant it the `Cosmos DB Built-in Data Reader` role on Cosmos DB
1. Add a new environment variable `TranscriptionsDatabase__accountEndpoint` to the Function App

### Simulate errors and added latency

Use the following environment variables to inject errors and latency:

| App setting        | Default value | Description                                           |
|--------------------|---------------|-------------------------------------------------------|
| ERROR_RATE         | 0             | Percentage of errors. Set a number between 0 and 100. |
| LATENCY_IN_SECONDS | 0             | Extra latency in seconds                              |

Use Application Insights to investigate these issues.

