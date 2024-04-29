using Core.Logger.HelkLogEntry;
using Core.Logger.NoSql;
using System.Threading.Tasks;

namespace Core.Logger.Interfaces
{
    public interface ILoggerMongoDBContext
    {
        AppConfigurations GetAppConfigurations();
        void CreateAppConfiguration(AppConfigurations conf);
        Task SaveLogEntry<T>(StandardHelkLogEntry<T> logEntry, string logCollectionName);
    }
}
