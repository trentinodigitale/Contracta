using MongoDB.Driver;

namespace Core.Repositories.NoSql.Interfaces
{
    public interface INoSqlAction<TOut, TIn>
    {
        TOut Execute(TIn param, IClientSessionHandle session = null);
    }
}
