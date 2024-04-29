using Core.Repositories.NoSql.Interfaces;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System.Runtime.Serialization;
using System.Text.Json.Serialization;

namespace Core.Repositories.NoSql.AbstractClasses
{
    public abstract class AbsNoSqlCollection : INoSqlCollection
    {
        /// <summary>
        /// _id used inside mongo DB
        /// </summary>
        [BsonId]
        [JsonIgnore]
        public virtual ObjectId _id { get; set; }

        /// <summary>
        /// Id used for JSON serialization from and to client
        /// </summary>
        [DataMember]
        [BsonIgnore]
        public virtual string Id
        {
            get { return _id.ToString(); }
            set { if (!(value is null)) _id = ObjectId.Parse(value); }
        }
    }
}
