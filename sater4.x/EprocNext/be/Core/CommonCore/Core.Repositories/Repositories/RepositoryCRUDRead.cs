using Core.Repositories.Interfaces;
using Dapper;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using Microsoft.Extensions.Configuration;
using Core.Repositories.Abstractions.Interfaces;
using System.Diagnostics.CodeAnalysis;
using Core.Repositories.Common;
using System.Data.SqlClient;

namespace Core.Repositories.Repositories
{
    public partial class RepositoryCrud<TDto, TModel, TRes> : RepositorySecurity, IRepositoryCrud<TDto>
        where TDto : class, IDtoResolver, new()
        where TRes : IResolver, new()
        where TModel : class, new()
    {
        #region Private parameters

        public readonly IClauseNormalizer Normalizer;
        private readonly IMapper _map;
        internal Func<TModel, bool, TDto> CalcHash;

        protected SqlConnection SqlServerConnection => Connection as SqlConnection;

        #endregion Private parameters

        #region Public parameters
        /// <summary>
        /// This is the Factory method to generate CalcHashFunc
        /// </summary>
        /// <typeparam name="TDBModel">Model type</typeparam>
        /// <typeparam name="TResDto">Dto result type</typeparam>
        /// <returns>Func that maps TDBModel to TResDto and calc hash inside Dto if bool parameter is true</returns>
        public Func<TDBModel, bool, TResDto> CalcHashFuncFactory<TDBModel, TResDto>() where TResDto : IDtoResolver, new() =>
            (model, applySecurityHash) =>
            {
                if (model == null) return default;
                var dto = _map.Map<TResDto>(model);
                if (applySecurityHash)
                    dto = ApplyHashOnDto(dto);
                return dto;
            };

        public Func<TDto, string> CalcIdForHashFuncFactory() =>
            (dto) => KeyIdValues(dto)?.OrderBy(el => el.ToString())?.Select(el => el?.ToString()).Aggregate((l, r) => l + r);

        public Func<TDto, TDto> CalcHashOnDtoFuncFactory() => (dto) => ApplyHashOnDto(dto);

        protected TResDto ApplyHashOnDto<TResDto>(TResDto dto)
        {
            if (typeof(ISecurityDTO).IsAssignableFrom(typeof(TResDto)))
            {
                var dtoHash = typeof(TResDto).GetProperty(nameof(ISecurityDTO.Hash));
                try
                {
                    dtoHash.SetValue(dto, GetHash(KeyIdValues(dto)?.OrderBy(el => el.ToString())?.Select(el => el?.ToString()).Aggregate((l, r) => l + r)));
                }
                catch
                {
                    throw new ArgumentException("Entity doesn't have any Key needed to create hash");
                }
            }
            return dto;
        }

        /// <summary>
        /// To inject basic funciotn to build and insert low level tenant checking
        /// </summary>
        public Func<long, string, string> BuildTenantWhereCondition { get; set; } = null;

        /// <summary>
        /// To inject basic parameters used by BuildTenantCheckCondition
        /// </summary>
        public Func<long, object, IClauseNormalizer, IDictionary<string, object>> BuildTenantBaseParameters { get; set; } = null;

        #endregion Public parameters

        #region Ctor
        public RepositoryCrud(IConfiguration config, ISqlSessionProvider session, IMapper map) : base(config, session)
        {
            _map = map;
            Normalizer = new QueryResolver(new TRes());
            CalcHash = CalcHashFuncFactory<TModel, TDto>();
        }
        #endregion

        #region Get methods
        public virtual TDto Get(long tenantId, object id, string whereConditions = "", object parameters = null, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true)
        {
            if (BuildTenantWhereCondition != null) whereConditions = BuildTenantWhereCondition(tenantId, whereConditions);
            if (BuildTenantBaseParameters != null) parameters = BuildTenantBaseParameters(tenantId, parameters, Normalizer);

            string normalizedQuery = !string.IsNullOrWhiteSpace(whereConditions) ? $"{ (whereConditions.Contains("WHERE", StringComparison.InvariantCultureIgnoreCase) ? "" : "WHERE")} { Normalizer.NormalizeWhere(whereConditions)}": $"WHERE {KeyIdColumName<TModel>().FirstOrDefault()}=@Id ";
            string query = $"SELECT TOP 1 * " +
                $"FROM {typeof(TDto).DbTableName()} " +
                $"{normalizedQuery} ";
            if (!string.IsNullOrWhiteSpace(whereConditions)) query = $"{query} AND {KeyIdColumName<TModel>().FirstOrDefault()}=@Id";
            var normallizedParameters = Normalizer.MergeAnonimousQueryParameters(new { Id = id }, parameters);
            return CalcHash(Connection.Query<TModel>(query, new DynamicParameters(normallizedParameters), transaction, false, commandTimeout, CommandType.Text).FirstOrDefault(), applySecurityHash);
        }

        public virtual async Task<TDto> GetAsync(long tenantId, object id, string whereConditions = "", object parameters = null, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true)
        {
            if (BuildTenantWhereCondition != null) whereConditions = BuildTenantWhereCondition(tenantId, whereConditions);
            if (BuildTenantBaseParameters != null) parameters = BuildTenantBaseParameters(tenantId, parameters, Normalizer);

            string normalizedQuery = !string.IsNullOrWhiteSpace(whereConditions) ? $"{ (whereConditions.Contains("WHERE", StringComparison.InvariantCultureIgnoreCase) ? "" : "WHERE")} { Normalizer.NormalizeWhere(whereConditions)}": $"WHERE {KeyIdColumName<TModel>().FirstOrDefault()}=@Id ";
            string query = $"SELECT TOP 1 * " +
                $"FROM {typeof(TDto).DbTableName()} " +
                $"{normalizedQuery} ";
            if (!string.IsNullOrWhiteSpace(whereConditions)) query = $"{query} AND {KeyIdColumName<TModel>().FirstOrDefault()}=@Id";
            var normallizedParameters = Normalizer.MergeAnonimousQueryParameters(new { Id = id }, parameters);
            return CalcHash((await Connection.QueryAsync<TModel>(query, new DynamicParameters(normallizedParameters), transaction, commandTimeout, CommandType.Text)).FirstOrDefault(), applySecurityHash);
        }

        public virtual IEnumerable<TDto> GetList(long tenantId, string whereConditions = "", object parameters = null, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true)
        {
            if (BuildTenantWhereCondition != null) whereConditions = BuildTenantWhereCondition(tenantId, whereConditions);
            if (BuildTenantBaseParameters != null) parameters = BuildTenantBaseParameters(tenantId, parameters, Normalizer);

            string whereNormalized = !string.IsNullOrEmpty(whereConditions) ? $"{(whereConditions.Contains("WHERE", StringComparison.InvariantCultureIgnoreCase)?"": "WHERE")} {Normalizer.NormalizeWhere(whereConditions)}" : whereConditions;
            return from l in Connection.GetList<TModel>(whereNormalized, parameters, transaction, commandTimeout)
                   select CalcHash(l, applySecurityHash);
        }

        public virtual async Task<IEnumerable<TDto>> GetListAsync(long tenantId, string whereConditions = "", object parameters = null, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true)
        {
            if (BuildTenantWhereCondition != null) whereConditions = BuildTenantWhereCondition(tenantId, whereConditions);
            if (BuildTenantBaseParameters != null) parameters = BuildTenantBaseParameters(tenantId, parameters, Normalizer);

            string whereNormalized = !string.IsNullOrEmpty(whereConditions) ? $"{(whereConditions.Contains("WHERE", StringComparison.InvariantCultureIgnoreCase) ? "" : "WHERE")} {Normalizer.NormalizeWhere(whereConditions)}" : whereConditions;
            return from l in await Connection.GetListAsync<TModel>(whereNormalized, parameters, transaction, commandTimeout)
                   select CalcHash(l, applySecurityHash);
        }

        public virtual IEnumerable<TDto> GetListPaged(long tenantId, int pageNumber, int rowsPerPage, string orderBy, string whereConditions = "", object parameters = null, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true)
        {
            if (BuildTenantWhereCondition != null) whereConditions = BuildTenantWhereCondition(tenantId, whereConditions);
            if (BuildTenantBaseParameters != null) parameters = BuildTenantBaseParameters(tenantId, parameters, Normalizer);

            string whereNormalized = !string.IsNullOrWhiteSpace(whereConditions) ? $"{(whereConditions.Contains("WHERE", StringComparison.InvariantCultureIgnoreCase) ? "" : "WHERE")} {Normalizer.NormalizeWhere(whereConditions)}" : whereConditions;
            string ordebyNormalized = Normalizer.NormalizeorderBy(orderBy);
            return Connection.GetListPaged<TModel>(pageNumber, rowsPerPage, whereNormalized, ordebyNormalized, parameters, transaction, commandTimeout).Select(el => CalcHash(el, applySecurityHash));
        }

        public virtual async Task<IEnumerable<TDto>> GetListPagedAsync(long tenantId, int pageNumber, int rowsPerPage, string orderBy, string whereConditions = "", object parameters = null, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true)
        {
            if (BuildTenantWhereCondition != null) whereConditions = BuildTenantWhereCondition(tenantId, whereConditions);
            if (BuildTenantBaseParameters != null) parameters = BuildTenantBaseParameters(tenantId, parameters, Normalizer);

            string whereNormalized = !string.IsNullOrWhiteSpace(whereConditions) ? $"{(whereConditions.Contains("WHERE", StringComparison.InvariantCultureIgnoreCase) ? "" : "WHERE")} {Normalizer.NormalizeWhere(whereConditions)}" : whereConditions;
            string ordebyNormalized = Normalizer.NormalizeorderBy(orderBy);
            return (await Connection.GetListPagedAsync<TModel>(pageNumber, rowsPerPage, whereNormalized, ordebyNormalized, parameters, transaction, commandTimeout)).Select(el => CalcHash(el, applySecurityHash));
        }

        #endregion Get methods

        #region Count methods
        public virtual int RecordCount(long tenantId, string whereConditions = "", object parameters = null, IDbTransaction transaction = null, int? commandTimeout = null)
        {
            if (BuildTenantWhereCondition != null) whereConditions = BuildTenantWhereCondition(tenantId, whereConditions);
            if (BuildTenantBaseParameters != null) parameters = BuildTenantBaseParameters(tenantId, parameters, Normalizer);

            string whereNormalized = !string.IsNullOrWhiteSpace(whereConditions) ? $"{(whereConditions.Contains("WHERE", StringComparison.InvariantCultureIgnoreCase) ? "" : "WHERE")} {Normalizer.NormalizeWhere(whereConditions)}" : whereConditions;
            return Connection.RecordCount<TModel>(whereNormalized, parameters, transaction, commandTimeout);
        }
        public virtual async Task<int> RecordCountAsync(long tenantId, string whereConditions = "", object parameters = null, IDbTransaction transaction = null, int? commandTimeout = null)
        {
            if (BuildTenantWhereCondition != null) whereConditions = BuildTenantWhereCondition(tenantId, whereConditions);
            if (BuildTenantBaseParameters != null) parameters = BuildTenantBaseParameters(tenantId, parameters, Normalizer);

            string whereNormalized = !string.IsNullOrWhiteSpace(whereConditions) ? $"{(whereConditions.Contains("WHERE", StringComparison.InvariantCultureIgnoreCase) ? "" : "WHERE")} {Normalizer.NormalizeWhere(whereConditions)}" : whereConditions;
            return await Connection.RecordCountAsync<TModel>(whereNormalized, parameters, transaction, commandTimeout);
        }

        #endregion Count methods

        #region Join methods

        protected IEnumerable<TDto> ExecuteJoinQuery(string queryNormalized, object parameters = null, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true)
        {
            var result = Connection.Query<TModel>(queryNormalized, parameters, transaction, commandTimeout: commandTimeout,
                commandType: CommandType.Text, buffered: true);
            return result.Select(el => CalcHash(el, applySecurityHash));
        }

        protected async Task<IEnumerable<TDto>> ExecuteJoinQueryAsync(string queryNormalized, object parameters = null, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true)
        {
            var result = await Connection.QueryAsync<TModel>(queryNormalized, parameters, transaction, commandTimeout: commandTimeout,
                commandType: CommandType.Text);
            return result.Select(el => CalcHash(el, applySecurityHash));
        }

        public virtual IEnumerable<TDto> GetListJoin<TJoin>(long tenantId, string joinConditions, object parameters = null, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true) where TJoin : IDtoResolver, ISecurityDTO, new()
        {
            Normalizer.AddResolver(Activator.CreateInstance((new TJoin()).Resolver) as IResolver);
            string query = $"{Normalizer.CreateBaseSelect<TDto>()} {joinConditions}";
            query = Normalizer.NormalizeFrom<TJoin>(query);
            var queryNormalized = Normalizer.NormalizeJoin(query);
            return ExecuteJoinQuery(queryNormalized, parameters, transaction, commandTimeout, applySecurityHash);
        }

        public virtual IEnumerable<TDto> GetListJoin<T1Join, T2Join>(long tenantId, string joinConditions, object parameters = null, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true) where T1Join : IDtoResolver, ISecurityDTO, new() where T2Join : IDtoResolver, ISecurityDTO, new()
        {
            Normalizer.AddResolver(Activator.CreateInstance((new T1Join()).Resolver) as IResolver);
            Normalizer.AddResolver(Activator.CreateInstance((new T2Join()).Resolver) as IResolver);
            string query = $"{Normalizer.CreateBaseSelect<TDto>()} {joinConditions}";
            query = Normalizer.NormalizeFrom<T1Join>(query);
            query = Normalizer.NormalizeFrom<T2Join>(query);
            return ExecuteJoinQuery(Normalizer.NormalizeJoin(query), parameters, transaction, commandTimeout, applySecurityHash);
        }

        public virtual IEnumerable<TDto> GetListJoin<T1Join, T2Join, T3Join>(long tenantId, string joinConditions, object parameters = null, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true) where T1Join : IDtoResolver, ISecurityDTO, new() where T2Join : IDtoResolver, ISecurityDTO, new() where T3Join : IDtoResolver, ISecurityDTO, new()
        {
            Normalizer.AddResolver(Activator.CreateInstance((new T1Join()).Resolver) as IResolver);
            Normalizer.AddResolver(Activator.CreateInstance((new T2Join()).Resolver) as IResolver);
            Normalizer.AddResolver(Activator.CreateInstance((new T3Join()).Resolver) as IResolver);
            string query = $"{Normalizer.CreateBaseSelect<TDto>()} {joinConditions}";
            query = Normalizer.NormalizeFrom<T1Join>(query);
            query = Normalizer.NormalizeFrom<T2Join>(query);
            query = Normalizer.NormalizeFrom<T3Join>(query);
            return ExecuteJoinQuery(Normalizer.NormalizeJoin(query), parameters, transaction, commandTimeout, applySecurityHash);
        }

        public virtual async Task<IEnumerable<TDto>> GetListJoinAsync<TJoin>(long tenantId, string joinConditions, object parameters = null, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true) where TJoin : IDtoResolver, ISecurityDTO, new()
        {
            Normalizer.AddResolver(Activator.CreateInstance((new TJoin()).Resolver) as IResolver);
            string query = $"{Normalizer.CreateBaseSelect<TDto>()} {joinConditions}";
            query = Normalizer.NormalizeFrom<TJoin>(query);
            return await ExecuteJoinQueryAsync(Normalizer.NormalizeJoin(query), parameters, transaction, commandTimeout, applySecurityHash);
        }

        public virtual async Task<IEnumerable<TDto>> GetListJoinAsync<T1Join, T2Join>(long tenantId, string joinConditions, object parameters = null, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true) where T1Join : IDtoResolver, ISecurityDTO, new() where T2Join : IDtoResolver, ISecurityDTO, new()
        {
            Normalizer.AddResolver(Activator.CreateInstance((new T1Join()).Resolver) as IResolver);
            Normalizer.AddResolver(Activator.CreateInstance((new T2Join()).Resolver) as IResolver);
            string query = $"{Normalizer.CreateBaseSelect<TDto>()} {joinConditions}";
            query = Normalizer.NormalizeFrom<T1Join>(query);
            query = Normalizer.NormalizeFrom<T2Join>(query);
            return await ExecuteJoinQueryAsync(Normalizer.NormalizeJoin(query), parameters, transaction, commandTimeout, applySecurityHash);
        }

        public virtual async Task<IEnumerable<TDto>> GetListJoinAsync<T1Join, T2Join, T3Join>(long tenantId, string joinConditions, object parameters = null, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true) where T1Join : IDtoResolver, ISecurityDTO, new() where T2Join : IDtoResolver, ISecurityDTO, new() where T3Join : IDtoResolver, ISecurityDTO, new()
        {
            Normalizer.AddResolver(Activator.CreateInstance((new T1Join()).Resolver) as IResolver);
            Normalizer.AddResolver(Activator.CreateInstance((new T2Join()).Resolver) as IResolver);
            Normalizer.AddResolver(Activator.CreateInstance((new T3Join()).Resolver) as IResolver);
            string query = $"{Normalizer.CreateBaseSelect<TDto>()} {joinConditions}";
            query = Normalizer.NormalizeFrom<T1Join>(query);
            query = Normalizer.NormalizeFrom<T2Join>(query);
            query = Normalizer.NormalizeFrom<T3Join>(query);
            return await ExecuteJoinQueryAsync(Normalizer.NormalizeJoin(query), parameters, transaction, commandTimeout, applySecurityHash);
        }

        #endregion Join methods

        #region Search methods

        private Func<string, string, string> ConcatWhereConditions = (string baseWhereCondition, string complexWhereCondition) =>
        {
            string concatClause = string.Empty;
            if (!string.IsNullOrWhiteSpace(baseWhereCondition) && !string.IsNullOrWhiteSpace(complexWhereCondition)) concatClause = " AND ";
            return $"{baseWhereCondition}{concatClause}{complexWhereCondition}";
        };

        public virtual ILookupResultDTO<TDto> Search(long tenantId, [NotNull]ILookupDTO lookup, string tenantIdWhereCondition = "", object parameters = null, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true)
        {
            PreSearch(lookup, tenantIdWhereCondition, ref parameters, out string whereConditions, out string orderByConditions);

            var records = GetListPaged(tenantId, lookup.PageNumber, lookup.PageSize, orderByConditions, ConcatWhereConditions(whereConditions, lookup.ComplexExpresionFilters), parameters, transaction, commandTimeout, applySecurityHash);
            var recordCount = RecordCount(tenantId, ConcatWhereConditions(whereConditions, lookup.ComplexExpresionFilters), parameters, transaction, commandTimeout);
            LookupResultDTO<TDto> ret = PostSearch(lookup, records, recordCount);
            return ret;
        }

        public virtual async Task<ILookupResultDTO<TDto>> SearchAsync(long tenantId, ILookupDTO lookup, string tenantIdWhereCondition = "", object parameters = null, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true)
        {
            PreSearch(lookup, tenantIdWhereCondition, ref parameters, out string whereConditions, out string orderByConditions);
            var records = await GetListPagedAsync(tenantId, lookup.PageNumber, lookup.PageSize, orderByConditions, ConcatWhereConditions(whereConditions, lookup.ComplexExpresionFilters), parameters, transaction, commandTimeout, applySecurityHash);
            var recordCount = await RecordCountAsync(tenantId, ConcatWhereConditions(whereConditions, lookup.ComplexExpresionFilters), parameters, transaction, commandTimeout);
            LookupResultDTO<TDto> ret = PostSearch(lookup, records, recordCount);
            return ret;
        }

        /// <summary>
        /// /// Condivisione codice tra Sync e Async
        /// </summary>
        /// <param name="lookup"></param>
        /// <param name="records"></param>
        /// <param name="recordCount"></param>
        /// <returns></returns>
        protected static LookupResultDTO<TDto> PostSearch(ILookupDTO lookup, IEnumerable<TDto> records, int recordCount)
        {
            return new LookupResultDTO<TDto>
            {
                Data = records,
                TotalRecords = recordCount,
                TotalPages = (long)Math.Ceiling((decimal)recordCount / (decimal)lookup.PageSize)
            };
        }

        /// <summary>
        /// Condivisione codice tra Sync e Async
        /// </summary>
        /// <param name="lookup"></param>
        /// <param name="tenantIdWhereCondition"></param>
        /// <param name="whereConditions"></param>
        /// <param name="orderByConditions"></param>
        protected void PreSearch(ILookupDTO lookup, string tenantIdWhereCondition, ref object parameter, out string whereConditions, out string orderByConditions)
        {
            IDictionary<string, object> filterParams = new Dictionary<string, object>();
            string lookupFilterNormalized = Normalizer.NormalizeLookUpFilter(lookup.Filters, ref filterParams);
            if (filterParams.Any())
            {
                Normalizer.MergeAnonimousQueryParametersFromDictory(ref filterParams, parameter);
                parameter = filterParams;
            }
            whereConditions = $"{tenantIdWhereCondition} {(!string.IsNullOrEmpty(lookupFilterNormalized) ? $"{(!string.IsNullOrEmpty(tenantIdWhereCondition) ? "AND" : "")} {lookupFilterNormalized}" : "")}";
            orderByConditions = (lookup.Sorting == null || lookup.Sorting?.Count() == 0)
            ? KeyIdColumName<TDto>().Select(el => $"{el} asc").Aggregate((curr, next) => $"{curr},{next}")
            : Normalizer.NormalizeLookUpOrderBy(lookup.Sorting);
        }

        #endregion Search methods
    }
}
