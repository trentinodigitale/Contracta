using Microsoft.Extensions.Configuration;
using MongoDB.Bson;
using MongoDB.Driver;
using Xunit;
using Assert = Xunit.Assert;

namespace eProcurementNext.Session.Test
{
    public class SessionTest
    {
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

        public SessionTest()
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
        public void ConnectionStringTest()
        {
            //string connectionString = "mongodb://localhost:27017/local/AFLink_MaeTest";
            string connectionString2 = "mongodb://localhost:27017/local";

            var session = new Session(connectionString2);
            session.Init("costrites");
            //session.Load();
        }

        [Fact]
        public void InitTest()
        {
            var session = new Session();
            var now = DateTime.Now;
            var id = "tk" + now.ToString("HHmmss");

            try
            {
                session.Init(id);
                var lastUdate = session.LastUpdate;
                Assert.True((DateTime.UtcNow - session.LastUpdate).TotalMilliseconds < 3000);

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
        public void LoadTest()
        {
            var session = new Session();
            var now = DateTime.Now;
            var id = "tk" + now.ToString("HHmmss");

            try
            {
                session.Init(id);
                var lastUdate = session.LastUpdate;
                Assert.True((DateTime.UtcNow - session.LastUpdate).TotalMilliseconds < 3000);

                var filter = Builders<BsonDocument>.Filter.Eq("_id", id);
                var doc = this._collection
                    .Find(filter)
                    .FirstOrDefault();
                Assert.NotNull(doc);

                var session2 = new Session();
                session2.Load(id);
                Assert.NotEmpty(session2.SessionID);

            }
            finally
            {
                var filter = Builders<BsonDocument>.Filter.Eq("_id", id);
                var res = _collection.DeleteOne(filter);
            }
        }

        [Fact]
        public void SaveTest()
        {
            var session = new Session();
            var now = DateTime.Now;
            var id = "tk" + now.ToString("HHmmss");

            try
            {
                session.Init(id);

                //var val = session[SessionProperty.redirectback];

                const string IntValueKey = "intValue";

                session[IntValueKey] = 8;

                var value = "a";
                session[SessionProperty.redirectback] = value;

                session.Save();

                var session2 = new Session();
                session2.Load(id);
                var savedValue = session[SessionProperty.redirectback];
                Assert.NotEmpty(savedValue);
                Assert.Equal(value, savedValue);

                int savedIntValue = session2[IntValueKey];

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
        public void DeleteTest()
        {
            var session = new Session();
            var now = DateTime.Now;
            var id = "tk" + now.ToString("HHmmss");

            try
            {
                session.Init(id);
                const string IntValueKey = "intValue";
                session[IntValueKey] = 8;

                var value = "a";
                session[SessionProperty.redirectback] = value;
                session.Save();

                session.Delete();

                var filter = Builders<BsonDocument>.Filter.Eq("_id", id);
                var doc = this._collection
                    .Find(filter)
                    .FirstOrDefault();
                Assert.Null(doc);
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
            string id = DateTime.Now.ToString("yyyyMMddHHmmss");
            Session session = new Session();

            try
            {
                session.Init(id);
                int[,] ints = { { 1, 2 }, { 3, 4 } };
                //dynamic[,] intsDyn = (int[,])ints;    // TODO: verificare uso di dynamic
                session["ints"] = ints;
                session.Save();

                // Riprendo il valore salvato. Utilizzo un nuovo oggetto session
                // per non riprendere il valore salvato internamente.

                var session2 = new Session();
                session2.Load(id);
                dynamic t = session2["ints"];

                int[,] ints2 = t;
                //dynamic[,] ints3 = t!= null ? (int[,])t : null;
                Assert.Equal(ints.GetType(), ints2.GetType());
                Assert.Equal(ints, ints2);
                //Assert.Equal(ints.GetType(), ints3.GetType());
                //Assert.Equal(ints, ints3);
            }
            finally
            {
                var filter = Builders<BsonDocument>.Filter.Eq(SessionProperty.Id, id);
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
            string id = DateTime.Now.ToString("yyyyMMddHHmmss");
            Session session = new Session();

            try
            {
                session.Init(id);

                var key = "a";
                var value = 1;
                session[key.ToLower()] = value;
                session.Save();

                // salvo stessa proprietà con diverso case su oggetto differente
                // case ignorato perchè forzo a lower case
                var session2 = new Session();
                session2.Load(id);
                session2[key.ToUpper()] = value + 1;
                session2.Save();

                DateTime lastUpdate = session2.LastUpdate;

                // recupero proprietà salvata
                var session3 = new Session();
                session3.Load(id);

                // Quando salvo: case ignorato perchè forzo a lower case
                // quindi mi aspetto che val1 = val2
                var val1 = session3[key.ToLower()];
                var val2 = session3[key.ToUpper()];
                Assert.NotNull(val1);
                Assert.NotNull(val2);
                Assert.Equal(val1, val2);
            }
            finally
            {
                var filter = Builders<BsonDocument>.Filter.Eq(SessionProperty.Id, id);
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
            string id = DateTime.Now.ToString("yyyyMMddHHmmss");
            Session session = new Session();

            try
            {
                session.Init(id);

                var key = "a";
                var value = 1;

                session[key] = value;

                var session2 = new Session();
                session2.Load(id);

                var val = session2[key];

                // il salvataggio è automatico. Quindi mi aspetto che val
                // non è null ed è uguale a value
                Assert.NotNull(val);
                Assert.Equal(value, val);
            }
            finally
            {
                var filter = Builders<BsonDocument>.Filter.Eq(SessionProperty.Id, id);
                var partOfDoc = this._collection.Find(filter).FirstOrDefault();
                if (partOfDoc != null)
                {
                    var res = _collection.DeleteOne(filter);
                    var deleted = res.DeletedCount > 0 ? true : false;
                }
            }

        }


        //[Theory]
        //[InlineData(false)]
        ////[InlineData(true)]
        [Fact]
        public void RefreshTest(/*bool useExpired*/)
        {
            string id = DateTime.Now.ToString("yyyyMMddHHmmss");
            Session session = new Session();

            try
            {
                session.Init(id);
                Assert.True(session.Refresh(), "Expected session was refreshed");
                var timeout = session.Timeout;
                var longerThanTimeout = new TimeSpan(0, timeout + 1, 0);

                // setto per test. Viene aggiornata da Session.Refresh
                session[SessionProperty.LastUpdate] = DateTime.UtcNow.Subtract(longerThanTimeout);
                Assert.False(session.Refresh(), "Expected session was expired and so not refreshed");

                //if (!useExpired)
                //{
                //    // setto per test. Viene aggiornata da Session.Refresh
                //    session[SessionProperty.LastUpdate] = DateTime.UtcNow.Subtract(longerThanTimeout);

                //    Assert.False(session.Refresh(), "Expected session was expired and so not refreshed");
                //}
                //else
                //{
                //    // setto per test. Viene aggiornata da Session.Refresh
                //    session[SessionProperty.Expires] = DateTime.UtcNow;

                //    Assert.False(session.Refresh(), "Expected session was expired expired and so not");
                //}
            }
            finally
            {
                var filter = Builders<BsonDocument>.Filter.Eq(SessionProperty.Id, id);
                var partOfDoc = this._collection.Find(filter).FirstOrDefault();
                if (partOfDoc != null)
                {
                    var res = _collection.DeleteOne(filter);
                    var deleted = res.DeletedCount > 0 ? true : false;
                }
            }
        }


        //[Theory]
        //[InlineData(false)]
        //[InlineData(true)]
        [Fact]
        public void IsExpiredTest(/*bool useExpired*/)
        {
            string id = DateTime.Now.ToString("yyyyMMddHHmmss");
            Session session = new Session();

            try
            {
                session.Init(id);
                Assert.False(session.IsExpired(), "Expected session was not expired");
                var timeout = session.Timeout;
                var longerThanTimeout = new TimeSpan(0, timeout + 1, 0);

                // setto per test. Viene aggiornata da Session.Refresh
                session[SessionProperty.LastUpdate] = DateTime.UtcNow.Subtract(longerThanTimeout);
                Assert.True(session.IsExpired(), "Expected session was expired");

                //if (!useExpired)
                //{
                //    // setto per test. Viene aggiornata da Session.Refresh
                //    session[SessionProperty.LastUpdate] = DateTime.UtcNow.Subtract(longerThanTimeout);

                //    Assert.True(session.IsExpired(), "Expected session was expired");
                //}
                //else
                //{
                //    // setto per test. Viene aggiornata da Session.Refresh
                //    session[SessionProperty.Expires] = DateTime.UtcNow;

                //    Assert.True(session.IsExpired(), "Expected session was expired");
                //}

            }
            finally
            {
                var filter = Builders<BsonDocument>.Filter.Eq(SessionProperty.Id, id);
                var partOfDoc = this._collection.Find(filter).FirstOrDefault();
                if (partOfDoc != null)
                {
                    var res = _collection.DeleteOne(filter);
                    var deleted = res.DeletedCount > 0 ? true : false;
                }
            }
        }


#warning serve
        [Fact]
        public void DataSavingTest()
        {
            var session = new Session();

        }


        [Fact]
        public void GetOldSessionsIdsTest()
        {
            var ids = Session.GetOldSessionsIds();
        }

        [Fact(Skip = "da sistemare o togliere")]
        public void SessionTest_()
        {
            var ObjSession = new List<dynamic>();
            ObjSession.Add("objSes_value1_" + DateTime.Now.ToString("HHmm"));
            ObjSession.Add("objSes_value2_" + DateTime.Now.ToString("HHmm"));

            var session = new Session();

            session.Load("tk2");

            //session.Init("tk2", DateTime.Now.AddMinutes(120), "John");

            var newVal = "value2_mod_" + DateTime.Now.ToString("HHmm");
            session["prop2"] = newVal;
            var value = session["prop2"];

            //session.UserName = "John";
            var userName = session.USERNAME;

            session["prop3"] = "aa";

            session["session"] = ObjSession;

            session.Delete();
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