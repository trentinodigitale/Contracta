using Core.Logger.Types;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;

namespace Core.Logger.NoSql
{
    public class AppConfigurations
    {
        [BsonId]
        public ObjectId _id { get; set; }

        public int Type { get; set; }

        public DateTime LastUpdate { get; set; }

        public LoggerConfiguration Data { get; set; }
    }
}
