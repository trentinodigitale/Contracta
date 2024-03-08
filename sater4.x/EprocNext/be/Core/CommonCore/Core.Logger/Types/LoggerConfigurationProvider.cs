using Core.Logger.Interfaces;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using Microsoft.Extensions.Hosting;
using Core.Logger.NoSql;
using System.Threading.Tasks;

namespace Core.Logger.Types
{
    public class LoggerConfigurationProvider : ILoggerConfigurationProvider
    {
        public ILoggerConfiguration Configuration { get; }

        public LoggerConfigurationProvider(IOptions<LoggerConfiguration> conf, ILoggerMongoDBContext mongoDBContext, IHostEnvironment environment)
        {
            Configuration = LoadConfiguration(mongoDBContext, environment, conf.Value);
        }

        private ILoggerConfiguration LoadConfiguration(ILoggerMongoDBContext mongoDBContext, IHostEnvironment environment, LoggerConfiguration defaultLoggerConfiguration = null)
        {
            if (environment.EnvironmentName == "Testing")
                return defaultLoggerConfiguration;

            if (mongoDBContext.GetAppConfigurations() is var dbConfiguration && !(dbConfiguration is null))
                return dbConfiguration.Data;

            dbConfiguration = new AppConfigurations
            {
                LastUpdate = DateTime.Now,
                Type = 0,
                Data = defaultLoggerConfiguration ?? new LoggerConfiguration
                {
                    MinimunOutput = LogLevel.error,
                    EndPointSaveDictionary = new Dictionary<string, EndPointSave>
                    {
                        { "Stats", new EndPointSave { LogOutput = LogOutput.NoSql, EndPoint = "HelkStats" } },
                        { "Logs",  new EndPointSave { LogOutput = LogOutput.NoSql, EndPoint = "HelkLogs" } },
                    }
                }
            };

            mongoDBContext.CreateAppConfiguration(dbConfiguration);
            return dbConfiguration.Data;
        }
    }
}
