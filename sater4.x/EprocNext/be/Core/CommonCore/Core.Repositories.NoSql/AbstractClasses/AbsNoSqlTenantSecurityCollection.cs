using Core.Repositories.NoSql.Interfaces;
using MongoDB.Bson.Serialization.Attributes;

namespace Core.Repositories.NoSql.AbstractClasses
{
    public abstract class AbsNoSqlTenantSecurityCollection : AbsNoSqlCollection, INoSqlTenantSecurityCollection
    {
        public virtual long Tenant { get; set; }

        [BsonIgnore]
        public virtual uint Hash { get; set; }
    }
}
