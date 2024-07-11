namespace UnexpectedBehaviors
{
    public static class Chaos
    {
        private static int _errorRate = 0;
        private static int _latencyInSeconds = 0;

        static Chaos()
        {
            // Get the error rate from the environment variables
            if (!Int32.TryParse(Environment.GetEnvironmentVariable("ERROR_RATE"), out _errorRate))
            {
                _errorRate = 0;
            }

            // Get the extra injected latency from the environment variables
            if (!Int32.TryParse(Environment.GetEnvironmentVariable("LATENCY_IN_SECONDS"), out _latencyInSeconds))
            {
                _latencyInSeconds = 0;
            }
        }

        public static void Start()
        {
            // Simulating latency: sleep for _latencyInSeconds seconds
            if (_latencyInSeconds != 0) {
                Thread.Sleep(_latencyInSeconds * 1000);
            }

            // Simulating errors: throw errors with a probability of _errorRate
            if (_errorRate != 0 && Random.Shared.Next(0, 100) < _errorRate) {
                throw new Exception("Simulated error!");
            }
        }
    }
}
