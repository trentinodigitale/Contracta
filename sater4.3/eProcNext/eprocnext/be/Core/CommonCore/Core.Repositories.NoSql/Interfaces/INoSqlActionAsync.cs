using MongoDB.Driver;
using System.Threading.Tasks;

namespace Core.Repositories.NoSql.Interfaces
{
    public interface INoSqlActionAsync<TOut, TIn>
    {
        Task<TOut> ExecuteAsync(TIn param, IClientSessionHandle session = null);
    }
}
