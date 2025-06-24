using Microsoft.Azure.Functions.Worker;
using Microsoft.DurableTask;
using Microsoft.DurableTask.Client;
using Microsoft.Extensions.Logging;
using Azure.Identity;
using Azure.Storage.Blobs;
using Azure.Storage.Sas;
using Microsoft.Azure.Functions.Worker.Extensions.OpenAI.TextCompletion;

namespace FuncDurable
{
    public static class AudioTranscriptionOrchestration
    {
        [Function(nameof(AudioBlobUploadStart))]
        public static async Task AudioBlobUploadStart(
                [BlobTrigger("%STORAGE_ACCOUNT_CONTAINER%/{name}", Source = BlobTriggerSource.EventGrid, Connection = "STORAGE_ACCOUNT_EVENT_GRID")] Stream stream, string name,
                [DurableClient] DurableTaskClient client,
                FunctionContext executionContext)
        {
            ILogger logger = executionContext.GetLogger(nameof(AudioBlobUploadStart));

            logger.LogInformation($"Processing audio file {name}");

            var storageAccountNameUrl = Environment.GetEnvironmentVariable("STORAGE_ACCOUNT_URL") ?? throw new ArgumentNullException("STORAGE_ACCOUNT_URL");

            // Create a new Blob service client with Azure AD credentials.
            var blobServiceClient = new BlobServiceClient(new Uri(storageAccountNameUrl), new DefaultAzureCredential());
            var blobContainerClient = blobServiceClient.GetBlobContainerClient(Environment.GetEnvironmentVariable("STORAGE_ACCOUNT_CONTAINER"));
            var blobClient = blobContainerClient.GetBlobClient(name);

            var userDelegationKey = blobServiceClient.GetUserDelegationKey(DateTimeOffset.UtcNow,
                                                                            DateTimeOffset.UtcNow.AddMinutes(10));
            var sasBuilder = new BlobSasBuilder()
            {
                BlobContainerName = blobClient.BlobContainerName,
                BlobName = blobClient.Name,
                Resource = "b", // b for blob, c for container
                StartsOn = DateTimeOffset.UtcNow,
                ExpiresOn = DateTimeOffset.UtcNow.AddHours(2),
            };

            // Only read permission is necessary
            sasBuilder.SetPermissions(BlobSasPermissions.Read);

            // Add the SAS token to the container URI.
            var blobUriBuilder = new BlobUriBuilder(blobClient.Uri)
            {
                Sas = sasBuilder.ToSasQueryParameters(userDelegationKey, blobServiceClient.AccountName)
            };

            var audioFile = new AudioFile
            {
                Id = Guid.NewGuid().ToString(),
                Path = blobClient.Uri.ToString(),
                UrlWithSasToken = blobUriBuilder.ToUri().ToString()
            };

            logger.LogInformation($"Processing audio file {audioFile.Id}");

            string instanceId = await client.ScheduleNewOrchestrationInstanceAsync(nameof(AudioTranscriptionOrchestration), audioFile);

            logger.LogInformation("Started orchestration with ID = '{instanceId}'.", instanceId);
        }

        [Function(nameof(AudioTranscriptionOrchestration))]
        public static async Task RunOrchestrator(
                [OrchestrationTrigger] TaskOrchestrationContext context,
                AudioFile audioFile)
        {
            ILogger logger = context.CreateReplaySafeLogger(nameof(AudioTranscriptionOrchestration));
            if (!context.IsReplaying) { logger.LogInformation($"Processing audio file {audioFile.Id}"); }

            // Step1: TODO: Start transcription
            var jobUri = await context.CallActivityAsync<string>(nameof(StartTranscription), audioFile);
            audioFile.JobUri = jobUri;

            DateTime endTime = context.CurrentUtcDateTime.AddMinutes(2);

            while (context.CurrentUtcDateTime < endTime)
            {
                // Step2: TODO: Check if transcription is done
                var status = await context.CallActivityAsync<string>(nameof(CheckTranscriptionStatus), audioFile);

                if (!context.IsReplaying) { logger.LogInformation($"Status of the transcription of {audioFile.Id}: {status}"); }

                if (status == "Succeeded" || status == "Failed")
                {
                    // Step3: TODO: Get transcription
                    string transcription = await context.CallActivityAsync<string>(nameof(GetTranscription), audioFile);

                    if (!context.IsReplaying) { logger.LogInformation($"Retrieved transcription of {audioFile.Id}: {transcription}"); }

                    var audioTranscription = new AudioTranscription
                    {
                        Id = audioFile.Id,
                        Path = audioFile.Path,
                        Result = transcription,
                        Status = status
                    };

                    // Step4: Enrich the transcription
                    AudioTranscription enrichedTranscription = await context.CallActivityAsync<AudioTranscription>(nameof(EnrichTranscription), audioTranscription);

                    if (!context.IsReplaying) { logger.LogInformation($"Saving transcription of {audioFile.Id} to Cosmos DB"); }

                    // Step5: Save transcription
                    await context.CallActivityAsync(nameof(SaveTranscription), enrichedTranscription);

                    if (!context.IsReplaying) { logger.LogInformation($"Finished processing of {audioFile.Id}"); }
                    
                    break;
                }
                else
                {
                    // Wait for the next checkpoint
                    var nextCheckpoint = context.CurrentUtcDateTime.AddSeconds(5);
                    if (!context.IsReplaying) { logger.LogInformation($"Next check for {audioFile.Id} at {nextCheckpoint}."); }

                    await context.CreateTimer(nextCheckpoint, CancellationToken.None);
                }
            }
        }

        [Function(nameof(StartTranscription))]
        public static async Task<string> StartTranscription([ActivityTrigger] AudioFile audioFile, FunctionContext executionContext)
        {
            ILogger logger = executionContext.GetLogger(nameof(StartTranscription));
            logger.LogInformation($"Starting transcription of {audioFile.Id}");

            var jobUri = await SpeechToTextService.CreateBatchTranscription(audioFile.UrlWithSasToken, audioFile.Id);

            logger.LogInformation($"Job uri for {audioFile.Id}: {jobUri}");

            return jobUri;
        }


        [Function(nameof(CheckTranscriptionStatus))]
        public static async Task<string> CheckTranscriptionStatus([ActivityTrigger] AudioFile audioFile, FunctionContext executionContext)
        {
            ILogger logger = executionContext.GetLogger(nameof(CheckTranscriptionStatus));
            logger.LogInformation($"Checking the transcription status of {audioFile.Id}");
            var status = await SpeechToTextService.CheckBatchTranscriptionStatus(audioFile.JobUri!);
            return status;
        }


        [Function(nameof(GetTranscription))]
        public static async Task<string?> GetTranscription([ActivityTrigger] AudioFile audioFile, FunctionContext executionContext)
        {
            ILogger logger = executionContext.GetLogger(nameof(GetTranscription));
            var transcription = await SpeechToTextService.GetTranscription(audioFile.JobUri!);
            logger.LogInformation($"Transcription of {audioFile.Id}: {transcription}");
            return transcription;
        }

        [Function(nameof(EnrichTranscription))]
        public static AudioTranscription EnrichTranscription(
            [ActivityTrigger] AudioTranscription audioTranscription, FunctionContext executionContext,
            [TextCompletionInput("Summarize {Result}", ChatModel = "%CHAT_MODEL_DEPLOYMENT_NAME%")] TextCompletionResponse response
        )
        {
            ILogger logger = executionContext.GetLogger(nameof(EnrichTranscription));
            logger.LogInformation($"Enriching transcription {audioTranscription.Id}");
            audioTranscription.Completion = response.Content;
            return audioTranscription;
        }

        [Function(nameof(SaveTranscription))]
        [CosmosDBOutput("%COSMOS_DB_DATABASE_NAME%",
                 "%COSMOS_DB_CONTAINER_ID%",
                 Connection = "COSMOS_DB",
                 CreateIfNotExists = true)]
        public static AudioTranscription SaveTranscription([ActivityTrigger] AudioTranscription audioTranscription, FunctionContext executionContext)
        {
            ILogger logger = executionContext.GetLogger(nameof(SaveTranscription));
            logger.LogInformation("Saving the audio transcription...");

            return audioTranscription;
        }
    }


}
