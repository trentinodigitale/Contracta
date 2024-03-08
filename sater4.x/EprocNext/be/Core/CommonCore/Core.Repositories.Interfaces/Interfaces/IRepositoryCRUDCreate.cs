using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

namespace Core.Repositories.Interfaces
{
    public partial interface IRepositoryCrud<TDto>
    {
        #region Create Methods
        long? Insert(long tenantId, TDto entityToInsert, IDbTransaction transaction = null, int? commandTimeout = null);
        Tuple<TKey, uint> Insert<TKey>(long tenantId, TDto entityToInsert, IDbTransaction transaction = null, int? commandTimeout = null);
        Task<long?> InsertAsync(long tenantId, TDto entityToInsert, IDbTransaction transaction = null, int? commandTimeout = null);
        Task<Tuple<TKey, uint>> InsertAsync<TKey>(long tenantId, TDto entityToInsert, IDbTransaction transaction = null, int? commandTimeout = null);
        int BatchInsert(long tenantId, IEnumerable<TDto> entitiesToInsert, IDbTransaction transaction = null, int? commandTimeout = null);
        Task<int> BatchInsertAsync(long tenantId, IEnumerable<TDto> entitiesToInsert, IDbTransaction transaction = null, int? commandTimeout = null);
        int BulkInsert(long tenantId, IEnumerable<TDto> entitiesToInsert, IDbTransaction transaction = null, int? commandTimeout = null);
        Task<int> BulkInsertAsync(long tenantId, IEnumerable<TDto> entitiesToInsert, IDbTransaction transaction = null, int? commandTimeout = null);
        IEnumerable<TDto> BulkInsert(long tenantId, IEnumerable<TDto> entitiesToInsert, IDbTransaction transaction = null, int? commandTimeout = null, bool calcHash = true, bool isReturnIdentity = true);
        Task<IEnumerable<TDto>> BulkInsertAsync(long tenantId, IEnumerable<TDto> entitiesToInsert, IDbTransaction transaction = null, int? commandTimeout = null, bool calcHash = true, bool isReturnIdentity = true);
        #endregion Create Methods
    }
}
