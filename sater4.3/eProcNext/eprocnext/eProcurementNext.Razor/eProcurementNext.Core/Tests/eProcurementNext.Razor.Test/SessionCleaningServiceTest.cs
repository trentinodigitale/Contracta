using eProcurementNext.Session;
using Microsoft.Extensions.Configuration;
using MongoDB.Bson;
using MongoDB.Driver;
using Xunit;
using Assert = Xunit.Assert;

namespace eProcurementNext.Razor.Test
{
    public class SessionCleaningServiceTest
    {
        private MongoClient _client;
        private IMongoDatabase _database;
        private IMongoCollection<BsonDocument> _collection;

        private string GetConfigPath()
        {
            string configPath = "";

            var t = Path.GetFullPath(@"..\..\", Directory.GetCurrentDirectory());
            if (Path.GetDirectoryName(t).EndsWith("x64"))
            {
                configPath = Path.GetFullPath(@"..\..\..\..\..\..\eProcurementNext.Razor", Directory.GetCurrentDirectory());
            }
            else
            {
                configPath = Path.GetFullPath(@"..\..\..\..\..\eProcurementNext.Razor", Directory.GetCurrentDirectory());
            }

            return configPath;
        }

        public SessionCleaningServiceTest()
        {
            var configPath = GetConfigPath();

            if (SessionCommon.Configuration == null)
            {
                SessionCommon.Configuration = new ConfigurationBuilder()
                    .SetBasePath(configPath)
                    .AddJsonFile("appsettings.json", false, false)
                    //.AddEnvironmentVariables()
                    .Build();
                //SessionCommon.Configuration = _configuration;
            }

            _client = new MongoClient();
            _database = _client.GetDatabase("local");

            _collection = _database.GetCollection<BsonDocument>(SessionCommon.CollectionName);
            //_collection = _database.GetCollection<BsonDocument>("AFLink_MaeTest");
        }

        [Fact]
        public void DeleteOldSessionsTest()
        {
            var now = DateTime.Now;
            const int IdsNum = 5;

            var sessions = new List<eProcurementNext.Session.Session>();
            var ids = new List<string>();
            for (int i = 0; i < IdsNum; i++)
            {
                sessions.Add(new eProcurementNext.Session.Session());
                ids.Add("tk" + now.ToString("HHmmss_") + i.ToString());
            }

            try
            {
                for (int i = 0; i < IdsNum; i++)
                {
                    sessions[i].Init(ids[i]);
                }

                // setto la proprietà lastUpdate
                sessions[0][SessionProperty.LastUpdate] = sessions[0].LastUpdate.Subtract(new TimeSpan(0, SessionCommon.SessionTimeout + 2, 0));

                // per le modifiche a LastUpdate il salvataggio non è automatico
                sessions[0].Save();

                object? state = null;
                //SessionCleaningService.DeleteOldSessions(state);

                var filter = Builders<BsonDocument>.Filter.Eq("_id", ids[0]);
                var doc = this._collection.Find(filter).FirstOrDefault();
                Assert.Null(doc);

                for (int i = 1; i < IdsNum; i++)
                {
                    filter = Builders<BsonDocument>.Filter.Eq("_id", ids[i]);
                    doc = this._collection.Find(filter).FirstOrDefault();
                    Assert.NotNull(doc);
                }
            }
            finally
            {
                for (int i = 0; i < IdsNum; i++)
                {
                    var filter = Builders<BsonDocument>.Filter.Eq("_id", ids[i]);
                    var res = _collection.DeleteOne(filter);
                }
            }
        }

    }
}
