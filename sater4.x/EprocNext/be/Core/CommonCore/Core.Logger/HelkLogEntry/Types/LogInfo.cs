using Core.Logger.Types;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace Core.Logger.HelkLogEntry.Types
{
    public class LogInfo
    {
        /// <summary>
        /// Indicates the number of days which
        /// this log entry must be persisted in the logstash
        /// Example value: 15, 30, 60, 180
        /// </summary>
        public int Retention { get; set; }

        /// <summary>
        /// Indicates the level of the log
        /// Keyword value (i.e. info, debug, error)
        /// </summary>
        [BsonRepresentation(BsonType.String)]
        public LogLevel Level { get; set; }
    }
}
