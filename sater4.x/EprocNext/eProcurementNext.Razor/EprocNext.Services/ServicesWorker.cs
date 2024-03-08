using eProcurementNext.Application;
using eProcurementNext.CommonModule;

namespace eProcurementNext.Services
{
    public class ServicesWorker : BackgroundService
    {
        private readonly ILogger<ServicesWorker> _logger;

        private readonly IConfiguration _configuration;

        private Service _service = null;

        private Timer _timer = null;

        const string TimerIntervalKey = "TimerInterval";

        public ServicesWorker(IConfiguration configuration, ILogger<ServicesWorker> logger)
        {
            ConfigurationServices._configuration = configuration;

            _configuration = configuration;
            _logger = logger;
            _service = new Service(_configuration);

            ApplicationCommon.Configuration = _configuration;
        }

        public override Task StartAsync(CancellationToken cancellationToken)
        {
            bool success = false;
            _service.Load();
            _service.Start(ref success);
            if (!success)
            {
                return this.StopAsync(cancellationToken);
            }
            return base.StartAsync(cancellationToken);
        }

        public override Task StopAsync(CancellationToken cancellationToken)
        {
            _service.StopService();
            return base.StopAsync(cancellationToken);
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            //


            //bool success = false;
            //_service.Load();
            //_service.Start(ref success);
            //_timer = new Timer((state) => _service.TimerCallback(), null, 500, _service.TimerInterval);

            while (!stoppingToken.IsCancellationRequested)
            {
                //_logger.LogInformation("Worker running at: {time}", DateTimeOffset.Now);
                //await Task.Delay(1000, stoppingToken);
                //_service.TimerCallback2();
                _service.TimerCallback();
                await Task.Delay(Convert.ToInt32(_configuration.GetSection(TimerIntervalKey).Value));
            }
            //_service.StopService();
        }
    }
}