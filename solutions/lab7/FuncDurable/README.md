## Enriching transcriptions with Azure OpenAI

### Update Durabe function dependencies

1. Add a new dependency

```sh
dotnet add package Microsoft.Azure.Functions.Worker.Extensions.OpenAI --version 0.16.0-alpha
```

2. Add 2 new environment variables `AZURE_OPENAI_ENDPOINT` and `CHAT_MODEL_DEPLOYMENT_NAME` and point them to your model

3. Grant the role `Cognitive Services OpenAI User` to the Durable function app on the Azure OpenAI resource


### Enriching transcriptions

Update the Activity function `EnrichTranscription` to call Azure OpenAI via `TextCompletionInput`, and use the result to update the `Completion` field of the transcription.

