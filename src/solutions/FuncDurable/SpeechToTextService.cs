using System.Text;
using System.Text.Json;

namespace FuncDurable
{
    public static class SpeechToTextService
    {
        private static HttpClient httpClient = new()
        {
            BaseAddress = new Uri(Environment.GetEnvironmentVariable("SPEECH_TO_TEXT_ENDPOINT")!),
            DefaultRequestHeaders = { { "Ocp-Apim-Subscription-Key", Environment.GetEnvironmentVariable("SPEECH_TO_TEXT_API_KEY")! } }
        };

        public static async Task<string> CreateBatchTranscription(string audioBlobSasUri, string? id)
        {
            using StringContent jsonContent = new(
                JsonSerializer.Serialize(new
                {
                    contentUrls = new List<string> { audioBlobSasUri },
                    locale = "en-US",
                    displayName = id ?? $"My Transcription {DateTime.UtcNow.ToLongTimeString()}",
                }),
                Encoding.UTF8,
                "application/json"
            );

            HttpResponseMessage httpResponse = await httpClient.PostAsync("/speechtotext/v3.1/transcriptions", jsonContent);
            var serializedJob = await httpResponse.Content.ReadAsStringAsync();

            var options = new JsonSerializerOptions
            {
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase
            };

            var job = JsonSerializer.Deserialize<TranscriptionJob>(serializedJob, options);

            if (job == null) {
                throw new Exception("Batch transcription creation failure");
            }

            return job.Self;
        }

        private static async Task<TranscriptionJob?> GetBatchTranscriptionJob(string jobUrl)
        {
            HttpResponseMessage httpResponse = await httpClient.GetAsync(jobUrl);
            var serializedJob = await httpResponse.Content.ReadAsStringAsync();



            var options = new JsonSerializerOptions
            {
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase
            };

            return JsonSerializer.Deserialize<TranscriptionJob>(serializedJob, options);
        }
        
        public static async Task<string> CheckBatchTranscriptionStatus(string jobUrl)
        {
            var job = await GetBatchTranscriptionJob(jobUrl);

            return job?.Status ?? "Unknown";
        }

        public static async Task<string> GetTranscription(string jobUrl)
        {
            var job = await GetBatchTranscriptionJob(jobUrl);

            // https://learn.microsoft.com/en-us/rest/api/speechtotext/transcriptions/get?view=rest-speechtotext-v3.2-preview.2&tabs=HTTP#status
            if (job?.Status == "Failed") {
                return "";
            }

            if (job?.Status != "Succeeded") {
                throw new Exception("Batch transcription not done yet");
            }

            var files = job?.Links.Files;

            HttpResponseMessage resultsHttpResponse = await httpClient.GetAsync(files);
            var serializedJobResults = await resultsHttpResponse.Content.ReadAsStringAsync();

            var options = new JsonSerializerOptions
            {
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase
            };

            var transcriptionResult = JsonSerializer.Deserialize<TranscriptionResult>(serializedJobResults, options);
            var transcriptionFileUrl = transcriptionResult?.Values.Where(value => value.Kind == "Transcription").First().Links.ContentUrl;

            if (transcriptionFileUrl == null)
            {
                throw new Exception("Transcription file url not found");
            }

            HttpResponseMessage transcriptionDetailsHttpResponse = await httpClient.GetAsync(transcriptionFileUrl);
            var serializedTranscriptionDetails = await transcriptionDetailsHttpResponse.Content.ReadAsStringAsync();
            var transcriptionDetails = JsonSerializer.Deserialize<TranscriptionDetails>(serializedTranscriptionDetails, options);
            var transcription = transcriptionDetails?.CombinedRecognizedPhrases.First().Display;

            if (transcription == null)
            {
                throw new Exception("Transcription result not found");
            }

            return transcription;
        }
    }
}
