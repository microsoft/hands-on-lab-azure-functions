using Microsoft.Azure.Functions.Worker;
using Microsoft.DurableTask;
using Microsoft.DurableTask.Client;
using Microsoft.Extensions.Logging;
using Azure.Storage.Blobs;
using Azure.Storage.Sas;

namespace FuncDurable
{
    public static class AudioTranscriptionOrchestration
    {
        [Function(nameof(AudioBlobUploadStart))]
        public static async Task AudioBlobUploadStart(
                [BlobTrigger("%STORAGE_ACCOUNT_CONTAINER%/{name}", Connection = "STORAGE_ACCOUNT_CONNECTION_STRING")] BlobClient blobClient,
                [DurableClient] DurableTaskClient client,
                FunctionContext executionContext)
        {
            ILogger logger = executionContext.GetLogger(nameof(AudioBlobUploadStart));

            var blobSasBuilder = new BlobSasBuilder(BlobSasPermissions.Read, DateTimeOffset.Now.AddMinutes(10));
            var audioBlobSasUri = blobClient.GenerateSasUri(blobSasBuilder);

            var audioFile = new AudioFile
            {
                Id = Guid.NewGuid().ToString(),
                Path = blobClient.Uri.ToString(),
                UrlWithSasToken = audioBlobSasUri.AbsoluteUri
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

            // Step1: Start transcription
            var jobUri = await context.CallActivityAsync<string>(nameof(StartTranscription), audioFile);
            audioFile.JobUri = jobUri;

            DateTime endTime = context.CurrentUtcDateTime.AddMinutes(2);

            while (context.CurrentUtcDateTime < endTime)
            {
                // Step2: Check if transcription is done
                var status = await context.CallActivityAsync<string>(nameof(CheckTranscriptionStatus), audioFile);
                if (!context.IsReplaying) { logger.LogInformation($"Status of the transcription of {audioFile.Id}: {status}"); }

                if (status == "Succeeded" || status == "Failed")
                {
                    // Step3: Get transcription
                    string transcription = await context.CallActivityAsync<string>(nameof(GetTranscription), audioFile);

                    if (!context.IsReplaying) { logger.LogInformation($"Retrieved transcription of {audioFile.Id}: {transcription}"); }

                    var audioTranscription = new AudioTranscription
                    {
                        Id = audioFile.Id,
                        Path = audioFile.Path,
                        Result = transcription,
                        Status = status
                    };

                    if (!context.IsReplaying) { logger.LogInformation($"Saving transcription of {audioFile.Id} to Cosmos DB"); }

                    // Step4: Save transcription
                    await context.CallActivityAsync(nameof(SaveTranscription), audioTranscription);

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

        [Function(nameof(SaveTranscription))]
        [CosmosDBOutput("%COSMOS_DB_DATABASE_NAME%",
                         "%COSMOS_DB_CONTAINER_ID%",
                         Connection = "COSMOS_DB_CONNECTION_STRING",
                         CreateIfNotExists = true)]
        public static AudioTranscription SaveTranscription([ActivityTrigger] AudioTranscription audioTranscription, FunctionContext executionContext)
        {
            ILogger logger = executionContext.GetLogger(nameof(SaveTranscription));
            logger.LogInformation("Saving the audio transcription...");
         
            return audioTranscription;
        }
    }
}
