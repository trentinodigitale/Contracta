using System;
using System.Collections.Generic;
using System.Data;
using System.Linq.Expressions;
using System.Threading.Tasks;

namespace Core.Repositories.Interfaces
{
    public partial interface IRepositoryCrud<TDto>
    {
        #region Update Methods
        int Update(TDto entityToUpdate, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true);
        int Update<TWhat>(TDto entityToUpdate, TWhat what, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true);
        Task<int> UpdateAsync(TDto entityToUpdate, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true);
        Task<int> UpdateAsync<TWhat>(TDto entityToUpdate, TWhat what, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true);
        int BatchUpdate(long tenantId, IEnumerable<TDto> entitiesToUpdate, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true);
        Task<int> BatchUpdateAsync(long tenantId, IEnumerable<TDto> entitiesToUpdate, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true);
        int BulkUpdate(long tenantId, IEnumerable<TDto> entitiesToUpdate, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true);
        Task<int> BulkUpdateAsync(long tenantId, IEnumerable<TDto> entitiesToUpdate, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true);
        #endregion Update Methods
    }
}
