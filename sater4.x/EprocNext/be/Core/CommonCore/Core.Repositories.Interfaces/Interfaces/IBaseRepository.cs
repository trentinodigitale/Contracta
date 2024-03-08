using System.Data;

namespace Core.Repositories.Interfaces
{
    public interface IBaseRepository
    {
        IDbConnection Connection { get; }
        IDbTransaction BeginTransaction();
    }
}
