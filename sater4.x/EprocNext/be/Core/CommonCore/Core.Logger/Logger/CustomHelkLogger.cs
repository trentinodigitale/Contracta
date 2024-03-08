using Core.Logger.AbstractClasses;
using Core.Logger.HelkLogEntry.Builders;
using Core.Logger.HelkLogEntry.Types;
using Core.Logger.Interfaces;
using Core.Logger.Sql;
using Core.Logger.Types;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Options;
using System.Threading.Tasks;

namespace Core.Logger.Logger
{
    public class CustomHelkLogger : AbsLogger, IHelkLogger
    {
        protected IHttpContextAccessor ContextAccessor { get; }
        protected ApplicationData DataFromConfiguration { get; }

        public CustomHelkLogger(
            ISqlUserInfo loggerRepository,
            ILoggerMongoDBContext loggerConfigurationDB,
            IHttpContextAccessor httpContextAccessor,
            IHostEnvironment hostingEnvironment,
            ILoggerConfigurationProvider conf,
            IEventHubClient eventHub,
            IOptions<ApplicationInfo> applicationInfo,
            IOptions<CloudInfo> cloudInfo,
            IOptions<HostInfo> serverInfo
        ) : base(loggerRepository, loggerConfigurationDB, conf, eventHub)
        {
            ContextAccessor = httpContextAccessor;
            DataFromConfiguration = new ApplicationData
            {
                Application = applicationInfo.Value,
                Cloud = cloudInfo.Value,
                Env = hostingEnvironment.EnvironmentName,
                Server = serverInfo.Value
            };
        }

        protected async Task BuildAndSaveEntry<T>(ILogEntryData<T> entry, string logType) where T: class
        {
            var builder = new StandardHelkLogEntryBuilder(ContextAccessor, SqlLogger, DataFromConfiguration);
            var result = builder.Build(entry);
            await SaveLog(result, logType);
        }

        public void Stat<T>(ILogEntryData<T> statsData) where T : class
        {
            var task = BuildAndSaveEntry(statsData, nameof(Stat));
            task.Wait();
        }

        public void Log<T>(ILogEntryData<T> entryData) where T : class
        {
            var task = BuildAndSaveEntry(entryData, nameof(Log));
            task.Wait();
        }

        public async Task StatAsync<T>(ILogEntryData<T> statsData) where T : class
        {
            await BuildAndSaveEntry(statsData, nameof(Stat));
        }

        public async Task LogAsync<T>(ILogEntryData<T> entryData) where T : class
        {
            await BuildAndSaveEntry(entryData, nameof(Log));
        }
    }
}
