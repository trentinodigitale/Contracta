using MongoDB.Bson;

namespace Core.Repositories.NoSql.Interfaces
{
    /// <summary>
    /// Identifies Entity Model class which keeps
    /// model for NoSql DB collections.
    /// </summary>
    public interface INoSqlCollection
    {
        ObjectId _id { get; set; }
    }
}
