using Microsoft.Extensions.Options;
using MongoDB.Driver;
using System.ComponentModel;
using System;
using Core.Repositories.NoSql.Attributes;
using Core.Repositories.NoSql.Types;
using Core.Repositories.NoSql.ExtensionMethods;
using Core.Repositories.NoSql.Interfaces;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;
using Common.NoSql.Attributes;

namespace Core.Repositories.NoSql.Data
{
    public class NoSqlDBContext<T> : INoSqlDBContext<T>
    {
        private string DatabaseName { get; } = null;
        private string CollectionName { get; }
        private bool CappedEnabled { get; }
        private long CappedSize { get; }
        private MongoClient Client { get; }

        public NoSqlDBContext(IOptions<MongoConnection> settings)
        {
            DatabaseName = settings.Value.Database;
            Client = new MongoClient(settings.Value.ConnectionString);
            CollectionName = typeof(T).GetAttributeValue((DescriptionAttribute descr) => descr.Description);
            CappedEnabled = typeof(T).GetCustomAttribute(typeof(MongoCappedAttribute)) != null;
            if (CappedEnabled)
                CappedSize = typeof(T).GetAttributeValue((MongoCappedAttribute capped) => capped.Size);

            InitCollection();
        }

        public IMongoDatabase Database => Client.GetDatabase(DatabaseName);

        public IMongoCollection<T> Collection => Database.GetCollection<T>(CollectionName);

        private void InitCollection()
        {
            if (!Database.ListCollectionNames().ToList().Any(s => s == CollectionName))
            {
                if (CappedEnabled)
                    Database.CreateCollection(CollectionName, new CreateCollectionOptions { Capped = true, MaxSize = CappedSize });
                else
                    Database.CreateCollection(CollectionName);
            }

            var collection = Database.GetCollection<T>(CollectionName);

            // 2 - Create index if model have any specified key attribute
            var keys = typeof(T).GetProperties()
                .Where(x => Attribute.IsDefined(x, typeof(MongoIndexAttribute)));

            foreach (var k in keys)
            {
                var options = new CreateIndexOptions()
                {
                    Unique = k.GetCustomAttribute<MongoIndexAttribute>()?.Unique ?? false,
                    Name = k.GetCustomAttribute<MongoIndexAttribute>().Name ?? k.Name,
                    Sparse = k.GetCustomAttribute<MongoIndexAttribute>()?.Sparse ?? true,
                };

                if (k.PropertyType == typeof(string))
                {
                    var field = new StringFieldDefinition<T>(k.Name);
                    var indexDefinition = new IndexKeysDefinitionBuilder<T>().Ascending(field);
                    collection.Indexes.CreateOneAsync(new CreateIndexModel<T>(indexDefinition, options)).Wait();
                }
                else
                {
                    IndexKeysDefinition<T> keyCode = $"{{ {k.Name}: 1 }}";
                    collection.Indexes.CreateOneAsync(new CreateIndexModel<T>(keyCode, options)).Wait();
                }
            }
        }

        public IClientSessionHandle StartSession()
        {
            return Client.StartSession();
        }

        public async Task<IClientSessionHandle> StartSessionAsync()
        {
            return await Client.StartSessionAsync();
        }
    }
}