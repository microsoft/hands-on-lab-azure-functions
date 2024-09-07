using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace FuncStd
{
    public class GetTranscriptions
    {
        private readonly ILogger _logger;

        public GetTranscriptions(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<GetTranscriptions>();
        }

        [Function(nameof(GetTranscriptions))]
        public IActionResult Run(
            [HttpTrigger(AuthorizationLevel.Function, "get")] HttpRequest req,
            [CosmosDBInput(
                databaseName: "%COSMOS_DB_DATABASE_NAME%",
                containerName: "%COSMOS_DB_CONTAINER_ID%",
                Connection = "COSMOS_DB",
                SqlQuery = "SELECT * FROM c ORDER BY c._ts DESC OFFSET 0 LIMIT 50")
            ] IEnumerable<Transcription> transcriptions
        )
        {
            _logger.LogInformation("C# HTTP trigger function processed a request.");

            // Simulate unexpected bahaviors
            UnexpectedBehaviors.Simulate();

            return  new JsonResult(transcriptions);
        }
    }
}