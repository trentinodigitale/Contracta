using MongoDB.Bson;
using MongoDB.Driver;

namespace eProcurementNext.CommonModule
{
    public class MongoLog
    {
        public static string ConnectionString;

        public MongoLog(string collectionName = "eProcNextLog")
        {
            _client = new MongoClient(ConnectionString);
            _database = _client.GetDatabase(MongoUrl.Create(ConnectionString).DatabaseName);
            _collection = _database.GetCollection<BsonDocument>(collectionName);
        }

        public MongoClient _client;

        public IMongoDatabase _database;

        public IMongoCollection<BsonDocument> _collection;

        public void Insert(string message)
        {
            long now = Basic.CLng(Basic.ConvertTicksToMilliSeconds(DateTime.Now.Ticks));
            BsonElement bsonElement = new BsonElement(message, now.ToString());
            _collection.InsertOne(new BsonDocument(bsonElement));
        }

        public void Insert(string message, long start, long end)
        {
            BsonElement bsonElement = new BsonElement(message, $@"Tempo di esecuzione (ms): {Basic.ConvertTicksToMilliSeconds(end) - Basic.ConvertTicksToMilliSeconds(start)}");
            _collection.InsertOne(new BsonDocument(bsonElement));
        }

        public void DropCollection()
        {
            _database.DropCollection(_collection.CollectionNamespace.CollectionName);
        }



    }

}
