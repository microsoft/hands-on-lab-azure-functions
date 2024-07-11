using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using UnexpectedBehaviors;

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

        public AudioUpload(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<AudioUpload>();
        }

        [Function(nameof(AudioUpload))]
        public AudioUploadOutput Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "post")] HttpRequest req
        )
        {
            _logger.LogInformation("Processing a new audio file upload request");

            // Simulate unexpected bahaviors
            Chaos.Start();

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
