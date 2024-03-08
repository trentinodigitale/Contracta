using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

namespace Core.Repositories.Interfaces
{
    public partial interface IRepositoryCrud<TDto>
    {
        #region Delete Methods
        int Delete(object id, uint hash, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true);
        int Delete(TDto entityToDelete, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true);
        int Delete(String whereCondition, IDbTransaction transaction = null, int? commandTimeout = null);
        int BatchDelete(IEnumerable<(long id, uint hash)> ids, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true);
        int BulkDelete(IEnumerable<TDto> entities, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true);
        Task<int> DeleteAsync(object id, uint hash, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true);
        Task<int> DeleteAsync(TDto entityToDelete, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true);
        Task<int> DeleteAsync(String whereCondition, IDbTransaction transaction = null, int? commandTimeout = null);
        Task<int> BatchDeleteAsync(IEnumerable<(long id, uint hash)> ids, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true);
        Task<int> BulkDeleteAsync(IEnumerable<TDto> entities, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true);
        #endregion Delete Methods
    }
}
