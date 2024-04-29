using Core.Logger.HelkLogEntry.Types;
using Core.Logger.Types;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;

namespace Core.Logger.HelkLogEntry
{
    public class StandardHelkLogEntry<T>
    {
        /// <summary>
        /// Date and time for the actual log entry
        /// Example: 2016-05-23T08:05:34.853Z
        /// </summary>
        public DateTime Timestamp { get; set; }

        public HostInfo Client { get; set; }

        public HostInfo Server { get; set; }

        public CustomerInfo Customer { get; set; }

        [BsonRepresentation(BsonType.String)]
        public BusinessUnit Business_unit { get; set; }

        public ApplicationInfo App { get; set; }

        public CorrelationInfo Correlation { get; set; }

        public LogInfo Log { get; set; }

        public string Environment { get; set; }

        public string User { get; set; }

        public CloudInfo Cloud { get; set; }

        public EventInfo<T> Event { get; set; }

        public HttpInfo Http { get; set; }

        public ErrorInfo Error { get; set; }

        public StandardHelkLogEntry()
        { }

        public StandardHelkLogEntry(LogLevel level, int retention)
        {
            Log = new LogInfo { Level = level, Retention = retention };
        }
    }

    public class StandardHelkEntryDB<T> : StandardHelkLogEntry<T>
    {
        [BsonId]
        public ObjectId _id { get; set; }
    }
}
