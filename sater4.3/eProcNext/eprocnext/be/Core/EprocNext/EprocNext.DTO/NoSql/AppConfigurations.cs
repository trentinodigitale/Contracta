using Core.Repositories.NoSql.Interfaces;
using Core.Repositories.NoSql.Types;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;
using System.ComponentModel;

namespace Core.Repositories.NoSql.Model
{
    [Description("AppConfigurations")]
    public class AppConfigurations<T> : INoSqlCollection where T : class
    {
        [BsonId]
        public ObjectId _id { get; set; }

        public AppConfigurationsType Type { get; set; }

        public DateTime LastUpdate { get; set; }

        public T Data { get; set; }
    }
}
