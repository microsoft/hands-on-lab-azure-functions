namespace FuncStd
{
    public class Transcription
    {
        public string id { get; set; }
        public string path { get; set; }
        public string result { get; set; }
        public string status { get; set; }
        public string? completion { get; set; }
        public int _ts { get; set; }
    }
}