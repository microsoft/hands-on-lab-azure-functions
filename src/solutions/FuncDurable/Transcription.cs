namespace FuncDurable
{
    public class TranscriptionJobFiles
    {
        public string Files { get; set; }
    }

    public class TranscriptionJob
    {
        public string Self { get; set; }

        public string Status { get; set; }

        public TranscriptionJobFiles Links { get; set; }
    }

    public class TranscriptionResultValueFile
    {
        public string ContentUrl { get; set; }
    }

    public class TranscriptionResultValue
    {
        public string Kind { get; set; }
        public TranscriptionResultValueFile Links { get; set; }
    }

    public class TranscriptionResult
    {
        public TranscriptionResultValue[] Values { get; set; }
    }

    public class Transcription
    {
        public string Display { get; set; }
    }

    public class TranscriptionDetails
    {
        public Transcription[] CombinedRecognizedPhrases { get; set; }
    }
}
