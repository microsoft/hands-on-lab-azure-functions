using System.Text.Json.Serialization;

namespace FuncDurable
{
    public abstract class Audio
    {
        [JsonPropertyName("id")]
        public string Id { get; set; }
        
        // Blob path uri
        [JsonPropertyName("path")]
        public string Path { get; set; }
    }

    public class AudioFile : Audio
    {
        [JsonPropertyName("urlWithSasToken")]
        public string UrlWithSasToken { get; set; }

        [JsonPropertyName("jobUri")]
        public string? JobUri { get; set; }
    }

    public class AudioTranscription : Audio
    {
        [JsonPropertyName("result")]
        public string Result { get; set; }

        [JsonPropertyName("status")]
        public string Status { get; set; }
    }
}