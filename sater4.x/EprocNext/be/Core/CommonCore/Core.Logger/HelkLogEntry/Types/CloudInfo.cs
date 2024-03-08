using Core.Logger.Types;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace Core.Logger.HelkLogEntry.Types
{
    public class CloudInstance
    {
        /// <summary>
        /// instance uuid
        /// </summary>
        public string Id { get; set; }
    }

    public class CloudInfo
    {
        /// <summary>
        /// Cloud provider, examples:
        /// aws (Amazon Web Service),
        /// az (Azure),
        /// gcp (Google Cloud Platform), ...
        /// </summary>
        [BsonRepresentation(BsonType.String)]
        public CloudProvider Provider { get; set; }

        /// <summary>
        /// Region keyword, example: westeurope, eu-west-1
        /// </summary>
        public string Region { get; set; }

        /// <summary>
        /// Service information, examples:
        /// aks (Azure Kubernet Service),
        /// ec2 (Amazon EC2),
        /// ecs (Amazon ECS)
        /// </summary>
        [BsonRepresentation(BsonType.String)]
        public CloudService Service { get; set; }

        /// <summary>
        /// Contains instance global identifier
        /// </summary>
        public CloudInstance Instance { get; set; }
    }
}
