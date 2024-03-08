using Microsoft.Extensions.Options;
using MongoDB.Driver;
using System;
using System.Linq;
using Core.Logger.Interfaces;
using Core.Logger.HelkLogEntry;
using Core.Logger.Types;
using System.Threading.Tasks;

namespace Core.Logger.NoSql
{
    internal class LoggerMongoDBContext : ILoggerMongoDBContext
    {
        private string DatabaseName { get; }
        private MongoClient Client { get; }
        private IMongoDatabase Database => Client.GetDatabase(DatabaseName);

        public LoggerMongoDBContext(IOptions<LogMongoDB> settings)
        {
            DatabaseName = settings.Value.Database;
            Client = new MongoClient(settings.Value.ConnectionString);
        }

        private IMongoCollection<AppConfigurations> Configurations
        {
            get { return Database.GetCollection<AppConfigurations>(nameof(AppConfigurations)); }
        }

        private IMongoCollection<StandardHelkLogEntry<T>> GetLogCollection<T>(string collectionName)
        {
            return Database.GetCollection<StandardHelkLogEntry<T>>(collectionName);
        }

        public AppConfigurations GetAppConfigurations()
        {
            try
            {
                var configurations = Configurations.AsQueryable();
                return configurations.Where(c => c.Type == 0).FirstOrDefault();
            }
            catch (Exception)
            {
                return null;
            }
        }

        public void CreateAppConfiguration(AppConfigurations conf)
        {
            try
            {
                Configurations.InsertOne(conf, new InsertOneOptions { BypassDocumentValidation = true });
            }
            catch (Exception)
            { }
        }

        public async Task SaveLogEntry<T>(StandardHelkLogEntry<T> logEntry, string logCollectionName)
        {
            try
            {
                await GetLogCollection<T>(logCollectionName).InsertOneAsync(logEntry, new InsertOneOptions { BypassDocumentValidation = true });
            }
            catch (Exception)
            { }
        }
    }
}