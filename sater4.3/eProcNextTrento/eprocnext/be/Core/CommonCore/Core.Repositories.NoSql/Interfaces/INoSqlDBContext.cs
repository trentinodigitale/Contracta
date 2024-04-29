using MongoDB.Driver;
using System.Threading.Tasks;

namespace Core.Repositories.NoSql.Interfaces
{
    public interface INoSqlDBContext<T>
    {
        IMongoCollection<T> Collection { get; }

        IClientSessionHandle StartSession();

        Task<IClientSessionHandle> StartSessionAsync();
    }
}
