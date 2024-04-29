using Core.Logger.HelkLogEntry;
using Core.Logger.Interfaces;
using Core.Logger.Sql;
using Core.Logger.Types;
using System;
using System.Threading.Tasks;

namespace Core.Logger.AbstractClasses
{
    public abstract class AbsLogger
    {
        protected ISqlUserInfo SqlLogger { get; }
        protected ILoggerMongoDBContext MongoDBContext { get; }
        public ILoggerConfiguration Configuration { get; }
        protected IEventHubClient EventHub { get; }

        protected AbsLogger(ISqlUserInfo sqlLogger, ILoggerMongoDBContext loggerConfigurationDB, ILoggerConfigurationProvider conf, IEventHubClient eventHub)
        {
            SqlLogger = sqlLogger;
            MongoDBContext = loggerConfigurationDB;
            EventHub = eventHub;
            Configuration = conf.Configuration;
        }

        private protected async Task SaveLog<T>(StandardHelkLogEntry<T> entry, string logsType)
        {
            if (entry.Log.Level > Configuration.MinimunOutput)
                return;

            if (!Configuration.EndPointSaveDictionary.TryGetValue(logsType, out var endPointOutput))
                throw new Exception("End Point not configured!");

            switch(endPointOutput.LogOutput)
            {
                case LogOutput.HELK:
                    await EventHub.Send(entry, endPointOutput.EndPoint, endPointOutput.EndPointName);
                    break;
                case LogOutput.NoSql:
                    await MongoDBContext.SaveLogEntry(entry, endPointOutput.EndPoint);
                    break;
                case LogOutput.Sql:
                    SqlLogger.SaveLogEntry(entry);
                    break;
                default:
                    throw new NotImplementedException();
            }
        }
    }
}
