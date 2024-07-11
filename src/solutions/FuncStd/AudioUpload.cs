using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace FuncStd
{

    public class AudioUploadOutput
    {
        [BlobOutput("%STORAGE_ACCOUNT_CONTAINER%/{rand-guid}.wav", Connection="STORAGE_ACCOUNT_CONNECTION_STRING")]
        public byte[]? Blob { get; set; }

        [HttpResult]
        public required IActionResult HttpResponse { get; set; }
    }

    public class AudioUpload
    {
        private readonly ILogger _logger;
        private readonly int _errorRate;

        public AudioUpload(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<AudioUpload>();

            // Get the error rate from the environment variables
            if (!Int32.TryParse(Environment.GetEnvironmentVariable("ERROR_RATE"), out _errorRate))
            {
                _errorRate = 0;
            }
        }

        [Function(nameof(AudioUpload))]
        public AudioUploadOutput Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "post")] HttpRequest req
        )
        {
            _logger.LogInformation("Processing a new audio file upload request");
            
            // Simulating errors: throw errors with a probability of _errorRate
            if (_errorRate != 0 && Random.Shared.Next(0, 100) < _errorRate) {
                _logger.LogInformation("We will throw an error for this request!");

                return new AudioUploadOutput()
                {
                    HttpResponse = new BadRequestObjectResult("Error!")
                };
            }

            // Get the first file in the form
            byte[]? audioFileData = null;
            var file = req.Form.Files[0];

            using (var memstream = new MemoryStream())
            {
                file.OpenReadStream().CopyTo(memstream);
                audioFileData = memstream.ToArray();
            }

            // Store the file as a blob and return a success response
            return new AudioUploadOutput()
            {
                Blob = audioFileData,
                HttpResponse = new OkObjectResult("Uploaded!")
            };
        }
    }
}
