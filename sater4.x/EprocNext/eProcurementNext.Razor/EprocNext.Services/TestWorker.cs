namespace eProcurementNext.Services
{
    public class TestWorker : BackgroundService
    {
        private readonly ILogger<TestWorker> _logger;

        public TestWorker(ILogger<TestWorker> logger)
        {
            _logger = logger;
        }

        const string path = @"C:\Temp\workerTest.txt";

        const string formatDate = "HHmmss";

        public override Task StartAsync(CancellationToken cancellationToken)
        {
            File.AppendAllText(path, $" START {DateTime.Now.ToString(formatDate)} START ");
            return base.StartAsync(cancellationToken);
        }

        public override Task StopAsync(CancellationToken cancellationToken)
        {
            File.AppendAllText(path, $" STOP {DateTime.Now.ToString(formatDate)} STOP ");
            return base.StopAsync(cancellationToken);
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            File.AppendAllText(path, $" EXECUTE {DateTime.Now.ToString(formatDate)} EXECUTE ");

            while (!stoppingToken.IsCancellationRequested)
            {
                File.AppendAllText(path, "*");
                //File.AppendAllText(path, DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));

                _logger.LogInformation("Worker running at: {time}", DateTimeOffset.Now);
                await Task.Delay(1000, stoppingToken);
            }
        }
    }
}