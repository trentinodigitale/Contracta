using Microsoft.Extensions.Configuration;
using MongoDB.Bson;
using MongoDB.Bson.Serialization;
using MongoDB.Driver;
using Xunit;
using Assert = Xunit.Assert;

namespace eProcurementNext.Cache.Test
{
    public class CacheTest
    {
        const string TestCollectionName = "testCollection";

        private MongoClient _client;
        private IMongoDatabase _database;
        private IMongoCollection<BsonDocument> _collection;

        //private readonly IConfiguration _configuration;

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

        public CacheTest()
        {
            if (CacheCommon.Configuration == null)
            {
                var configPath = GetConfigPath();

                var _configuration = new ConfigurationBuilder()
                    .SetBasePath(configPath)
                    .AddJsonFile("appsettings.json", false, false)
                    //.AddEnvironmentVariables()
                    .Build();

                CacheCommon.Configuration = _configuration;
            }

            string connectionString = CacheCommon.MongoDbConnectionString;

            string databaseName = "";
            if (string.IsNullOrEmpty(connectionString))
            {
                databaseName = "local";
                connectionString = "";
                _client = new MongoClient();
            }
            else
            {
                databaseName = MongoUrl.Create(connectionString).DatabaseName;
                _client = new MongoClient(connectionString);
            }

            _database = _client.GetDatabase(databaseName);

            //_database = _client.GetDatabase("local");

            _collection = _database.GetCollection<BsonDocument>(CacheCommon.CollectionName);
            //_collection = _database.GetCollection<BsonDocument>("AFLink_MaeTest");
        }


        [Fact]
        public void ConnectionStringTest()
        {
            string id = "costrites";
            try
            {
                string connectionString = "mongodb://localhost:27017/local";
                var cache = new EProcNextCache(connectionString, TestCollectionName);
                //cache.Init(id);
            }
            finally
            {
                var filter = Builders<BsonDocument>.Filter.Eq("_id", id);
                var res = _collection.DeleteOne(filter);
            }
        }

        [Fact]
        public void InitTest()
        {
            var cache = new EProcNextCache();

            //var id = EProcNextCache.IdKey + "_test";
            var id = "_test";
            //var id = "tk" + now.ToString("HHmmss");

            var now = DateTime.Now;

            try
            {
                //cache.Init(id);
                var lastUdate = cache.LastUpdate;

                Assert.True((DateTime.UtcNow - cache.LastUpdate).TotalMilliseconds < 3000);

                //var totalMilliseconds = (DateTime.UtcNow - cache.LastUpdate).TotalMilliseconds;
                //Assert.True(totalMilliseconds < 3000);

                cache.Save();

                var filter = Builders<BsonDocument>.Filter.Eq("_id", id);
                var doc = this._collection
                    .Find(filter)
                    .FirstOrDefault();
                Assert.NotNull(doc);
            }
            finally
            {
                var filter = Builders<BsonDocument>.Filter.Eq("_id", id);
                var res = _collection.DeleteOne(filter);
            }
        }

        //[Fact]
        //public void ATest()
        //{
        //    var cache = new EProcNextCache();

        //    var id = EProcNextCache.IdKey + "_test";

        //    cache.Load(id);

        //    cache["dt"] = DateTime.UtcNow;
        //    cache["a"] = 1;
        //}

        [Fact]
        public void LoadTest()
        {
            var cache = new EProcNextCache();

            var id = "_test";
            //var id = EProcNextCache.IdKey + "_test";

            var filter = Builders<BsonDocument>.Filter.Eq("_id", id);

            try
            {
                var lastUpdate = DateTime.UtcNow;

                var partOfDoc = this._collection
                    .Find(filter)
                    .FirstOrDefault();

                if (partOfDoc != null)
                {
                    var res = _collection.DeleteOne(filter);
                }

                var bsonDoc = new BsonDocument() {
                        { EProcNextCacheProperty.Id, id },
                        { EProcNextCacheProperty.LastUpdate, lastUpdate },
                    };
                _collection.InsertOne(bsonDoc);


                //// se non trovo il documento lo creo
                //if (partOfDoc == null)
                //{
                //    var bsonDoc = new BsonDocument() {
                //        { EProcNextCacheProperty.Id, id },
                //        { EProcNextCacheProperty.LastUpdate, lastUpdate },
                //    };
                //    _collection.InsertOne(bsonDoc);
                //}
                //else
                //{
                //    var update = Builders<BsonDocument>.Update.Set(EProcNextCacheProperty.Id, id);
                //    update = update.Set(EProcNextCacheProperty.LastUpdate, ((object)lastUpdate).ToBsonDocument());
                //    var res = _collection.UpdateOne(filter, update);
                //}

                partOfDoc = this._collection
                    .Find(filter)
                    .Project($"{{" +
                    $"{EProcNextCacheProperty.LastUpdate}:1}}")
                    .FirstOrDefault();
                Assert.NotNull(partOfDoc);

                // riprendo la data salvata (senza frazione di millisecondo)
                // così che possa fare il confronto
                var bsonValue = partOfDoc[EProcNextCacheProperty.LastUpdate];
                //Assert.True(bsonValue.GetType() == typeof(BsonDocument));
                if (bsonValue.GetType() == typeof(BsonDocument))
                {
                    lastUpdate = (DateTime)BsonSerializer.Deserialize<object>(bsonValue.AsBsonDocument);
                }
                else
                {
                    lastUpdate = (DateTime)bsonValue;
                }

                //cache.Load(id);
                Assert.Equal(lastUpdate, cache.LastUpdate);

                //TimeSpan timeSpan = lastUpdate - cache.LastUpdate;
                //Assert.True(timeSpan.Ticks < 9999);
            }
            finally
            {
                var res = _collection.DeleteOne(filter);
            }
        }

        [Fact]
        public void SaveTest()
        {
            //var id = EProcNextCache.IdKey + "_test";
            var id = "_test";
            //var id = "tk" + now.ToString("HHmmss");

            var cache = new EProcNextCache();
            var now = DateTime.Now;

            try
            {
                //cache.Init(id);

                //var val = session[SessionProperty.redirectback];

                string key = "key";
                const string IntValueKey = "intValue";

                cache[IntValueKey] = 8;

                var value = "a";
                cache[key] = value;

                cache.Save();

                var cache2 = new EProcNextCache();
                //cache2.Load(id);
                var savedValue = cache[key];
                Assert.NotEmpty(savedValue);
                Assert.Equal(value, savedValue);

                int savedIntValue = cache2[IntValueKey];

                var filter = Builders<BsonDocument>.Filter.Eq("_id", id);
                var doc = this._collection
                    .Find(filter)
                    .FirstOrDefault();
                Assert.NotNull(doc);
            }
            finally
            {
                var filter = Builders<BsonDocument>.Filter.Eq("_id", id);
                var res = _collection.DeleteOne(filter);
            }
        }


        [Fact]
        public void MultiDimensionalArrayTest()
        {
            var id = "_test";
            //var id = EProcNextCache.IdKey + "_test";
            //string id = DateTime.Now.ToString("yyyyMMddHHmmss");

            EProcNextCache cache = new EProcNextCache();

            try
            {
                //cache.Init(id);
                int[,] ints = { { 1, 2 }, { 3, 4 } };
                //dynamic[,] intsDyn = (int[,])ints;    // TODO: verificare uso di dynamic
                cache["ints"] = ints;
                cache.Save();

                // Riprendo il valore salvato. Utilizzo un nuovo oggetto session
                // per non riprendere il valore salvato internamente.

                var cache2 = new EProcNextCache();
                //cache2.Load(id);
                dynamic t = cache2["ints"];

                int[,] ints2 = t;
                //dynamic[,] ints3 = t!= null ? (int[,])t : null;
                Assert.Equal(ints.GetType(), ints2.GetType());
                Assert.Equal(ints, ints2);
                //Assert.Equal(ints.GetType(), ints3.GetType());
                //Assert.Equal(ints, ints3);
            }
            finally
            {
                var filter = Builders<BsonDocument>.Filter.Eq(EProcNextCacheProperty.Id, id);
                var partOfDoc = this._collection.Find(filter).FirstOrDefault();
                if (partOfDoc != null)
                {
                    var res = _collection.DeleteOne(filter);
                    var deleted = res.DeletedCount > 0 ? true : false;
                }
            }
        }

        /// <summary>
        /// Test per verificare che venga ignorato il case della chiave
        /// usata per recuperare il valore
        /// </summary>
        [Fact]
        public void IgnoreCaseTest()
        {
            //var id = EProcNextCache.IdKey + "_test";
            var id = "_test";
            //string id = DateTime.Now.ToString("yyyyMMddHHmmss");

            EProcNextCache cache = new EProcNextCache();

            try
            {
                //cache.Init(id);

                var key = "a";
                var value = 1;
                cache[key.ToLower()] = value;
                cache.Save();

                // salvo stessa proprietà con diverso case su oggetto differente
                // case ignorato perchè forzo a lower case
                var cache2 = new EProcNextCache();
                //cache2.Load(id);
                cache2[key.ToUpper()] = value + 1;
                cache2.Save();

                DateTime lastUpdate = cache2.LastUpdate;

                // recupero proprietà salvata
                var cache3 = new EProcNextCache();
                //cache3.Load(id);

                // Quando salvo: case ignorato perchè forzo a lower case
                // quindi mi aspetto che val1 = val2
                var val1 = cache3[key.ToLower()];
                var val2 = cache3[key.ToUpper()];
                Assert.NotNull(val1);
                Assert.NotNull(val2);
                Assert.Equal(val1, val2);
            }
            finally
            {
                var filter = Builders<BsonDocument>.Filter.Eq(EProcNextCacheProperty.Id, id);
                var partOfDoc = this._collection.Find(filter).FirstOrDefault();
                if (partOfDoc != null)
                {
                    var res = _collection.DeleteOne(filter);
                    var deleted = res.DeletedCount > 0 ? true : false;
                }
            }

        }

        [Fact]
        public void AutosaveTest()
        {
            var id = "_test";
            //var id = EProcNextCache.IdKey + "_test";
            //string id = DateTime.Now.ToString("yyyyMMddHHmmss");

            EProcNextCache cache = new EProcNextCache();

            try
            {
                //cache.Init(id);

                var key = "a";
                var value = 1;

                cache[key] = value;

                var cache2 = new EProcNextCache();
                //cache2.Load(id);

                var val = cache2[key];

                // il salvataggio è automatico. Quindi mi aspetto che val
                // non è null ed è uguale a value
                Assert.NotNull(val);
                Assert.Equal(value, val);
            }
            finally
            {
                var filter = Builders<BsonDocument>.Filter.Eq(EProcNextCacheProperty.Id, id);
                var partOfDoc = this._collection.Find(filter).FirstOrDefault();
                if (partOfDoc != null)
                {
                    var res = _collection.DeleteOne(filter);
                    var deleted = res.DeletedCount > 0 ? true : false;
                }
            }

        }


        /// <summary>
        /// https://www.mongodb.com/blog/post/quick-start-c-sharp-and-mongodb-starting-and-setup
        /// https://mongodb.github.io/mongo-csharp-driver/2.14/reference/bson/serialization/
        ///https://oz-code.com/blog/net-c-tips/how-to-mongodb-in-c-part-1
        ///
        /// 
        /// </summary>
        [Fact(Skip = "usato solo per testare uso di MongoDB")]
        public void MongoDBTest()
        {
            var dbClient = new MongoClient();

            var dbList = dbClient.ListDatabases().ToList();
            var database = dbClient.GetDatabase("local");

            var collection = database.GetCollection<BsonDocument>("AFLink_MaeTest");

            var id = "1";

            var filter = Builders<BsonDocument>.Filter.Eq("_id", id);

            var fullDoc1 = collection
                           .Find(filter)
                           .FirstOrDefault();

            if (fullDoc1 == null)
            {
                var bsonDoc = new BsonDocument() {
                    { "_id", 1 },
                    { "prop1", "value1" },
                    { "prop2", "value2" }
                };

                collection.InsertOne(bsonDoc);
            }

            var partOfDoc1 = collection
                .Find(filter)
                .Project("{prop2:1}")
                .FirstOrDefault();

            var prop2 = partOfDoc1.GetElement("prop2");

            var newVal = "value2_mod_" + DateTime.Now.ToString("HHmm");

            partOfDoc1.Set("prop2", newVal);
            //collection.UpdateOne(filter, partOfDoc1); // va in errore

            var update = Builders<BsonDocument>.Update.Set("prop2", newVal);
            collection.UpdateOne(filter, update);
        }

        [Fact(Skip = "usato solo per testare uso di MongoDB")]
        public void BsonDocumentTest()
        {
            var bsonDoc = new BsonDocument() {
                { "_id", "test" },
                { "a", 1},
            };
            bsonDoc.Add("b", 2);
        }
    }
}