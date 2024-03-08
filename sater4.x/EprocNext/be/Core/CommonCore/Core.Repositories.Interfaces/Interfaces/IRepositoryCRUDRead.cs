using Core.Repositories.Abstractions.Interfaces;
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

namespace Core.Repositories.Interfaces
{
    public partial interface IRepositoryCrud<TDto> : IBaseRepository, IRepositorySecurity
    {
        #region Hash Methods
        Func<TDto, string> CalcIdForHashFuncFactory();
        Func<TDBModel, bool, TResDto> CalcHashFuncFactory<TDBModel, TResDto>() where TResDto : IDtoResolver, new();
        Func<TDto, TDto> CalcHashOnDtoFuncFactory();
        #endregion

        #region Properties
        /// <summary>
        /// To inject basic funciotn to build and insert low level tenant checking
        /// </summary>
        Func<long, string, string> BuildTenantWhereCondition { get; set; }

        /// <summary>
        /// To inject basic parameters used by BuildTenantCheckCondition
        /// </summary>
        Func<long, object, IClauseNormalizer, IDictionary<string, object>> BuildTenantBaseParameters { get; set; }
        #endregion Properties

        #region Read Methods
        TDto Get(long tenantId, object id, string whereConditions = "", object parameters = null, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true);
        Task<TDto> GetAsync(long tenantId, object id, string whereConditions = "", object parameters = null, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true);
        IEnumerable<TDto> GetList(long tenantId, string whereConditions = "", object parameters = null, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true);
        Task<IEnumerable<TDto>> GetListAsync(long tenantId, string whereConditions = "", object parameters = null, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true);
        IEnumerable<TDto> GetListJoin<TJoin>(long tenantId, string joinConditions, object parameters = null, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true) where TJoin : IDtoResolver, ISecurityDTO, new();
        IEnumerable<TDto> GetListJoin<T1Join, T2Join>(long tenantId, string joinConditions, object parameters = null, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true) where T1Join : IDtoResolver, ISecurityDTO, new() where T2Join : IDtoResolver, ISecurityDTO, new();
        Task<IEnumerable<TDto>> GetListJoinAsync<TJoin>(long tenantId, string joinConditions, object parameters = null, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true) where TJoin : IDtoResolver, ISecurityDTO, new();
        Task<IEnumerable<TDto>> GetListJoinAsync<T1Join, T2Join>(long tenantId, string joinConditions, object parameters = null, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true) where T1Join : IDtoResolver, ISecurityDTO, new() where T2Join : IDtoResolver, ISecurityDTO, new();
        IEnumerable<TDto> GetListPaged(long tenantId, int pageNumber, int rowsPerPage, string conditions, string orderBy, object parameters = null, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true);
        Task<IEnumerable<TDto>> GetListPagedAsync(long tenantId, int pageNumber, int rowsPerPage, string conditions, string orderBy, object parameters = null, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true);
        ILookupResultDTO<TDto> Search(long tenantId, ILookupDTO lookup, string tenantIdWhereCondition = "", object parameters = null, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true);
        Task<ILookupResultDTO<TDto>> SearchAsync(long tenantId, ILookupDTO lookup, string tenantIdWhereCondition = "", object parameters = null, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true);
        int RecordCount(long tenantId, string conditions = "", object parameters = null, IDbTransaction transaction = null, int? commandTimeout = null);
        Task<int> RecordCountAsync(long tenantId, string conditions = "", object parameters = null, IDbTransaction transaction = null, int? commandTimeout = null);
        #endregion Read Methods
    }
}
