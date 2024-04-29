using AutoMapper;
using Core.Repositories.Interfaces;
using EprocNext.Repositories.Interfaces;
using EprocNext.Repositories.Models;
using Microsoft.Extensions.Configuration;
using Core.Repositories.Repositories;
using Dapper;
using System.Data;
using Core.Repositories.Common;
using System.Linq;
using System.Threading.Tasks;
using System;

namespace EprocNext.Repositories.Repositories
{
    /// <summary>
    /// This is the Repository implementation of CRUD repository
    /// </summary>
    public partial class ProfiliUtenteRepository: RepositoryCrud<ProfiliUtenteDTO, ProfiliUtente, ProfiliUtenteDTOMap>, IProfiliUtenteRepository
    {
        public ProfiliUtenteRepository(IConfiguration config, ISqlSessionProvider session, IMapper map) : base(config, session, map)
        {
            BuildTenantWhereCondition = (long tenantId, string basicWhereCondition) =>
            {
                string tenantCheckCondition = $"WHERE {nameof(ProfiliUtenteDTO.pfuIdAzi)}=@IdAzi";
                string concatWhere = $"{(!string.IsNullOrWhiteSpace(basicWhereCondition) ? $" AND ( {basicWhereCondition} )" : "")}";
                return $"{tenantCheckCondition} {concatWhere}";
            };

            BuildTenantBaseParameters = (long tenantId, object parameters, IClauseNormalizer normalizer) =>
            {
                return normalizer.MergeAnonimousQueryParameters(new { TenantId = tenantId }, parameters);
            };
        }

        // You can override here basic CRUD implementation
        // Or add new methods based on extended IAn01ProfiliUtenteRepository interface

        //public ProfiliUtenteRepository(IConfiguration config, ISqlSessionProvider session, IMapper map) : base(config, session, map)
        //{
        //    BuildTenantWhereCondition = (long tenantId, string basicWhereCondition) =>
        //    {
        //        string tenantCheckCondition = $"JOIN {typeof(ProfiliUtente).DbTableName()} " +
        //        $"ON {nameof(ProfiliUtente.IdPfu)} = {nameof(ProfiliUtenteAzeinda.IdPfu)} " +
        //        $"WHERE {nameof(ProfiliUtente.pfuIdAzi)}=@TenantId";
        //        string concatWhere = $"{(!string.IsNullOrWhiteSpace(basicWhereCondition) ? $" AND ( {basicWhereCondition} )" : "")}";
        //        return $"{tenantCheckCondition} {concatWhere}";
        //    };

        //    BuildTenantBaseParameters = (long tenantId, object parameters, IClauseNormalizer normalizer) =>
        //    {
        //        return normalizer.MergeAnonimousQueryParameters(new { TenantId = tenantId }, parameters);
        //    };
        //}

        private (string sqlQuery, DynamicParameters queryParams) BuildAccountForLoginQuery(string username, string password = null)
        {
            var sqlQuery = $@"
            Select *
            From {typeof(ProfiliUtente).DbTableName()} an03
            Where
                an03.{nameof(ProfiliUtente.pfuLogin)} = @Login
                {(!(password is null) ? $"And an03.{nameof(ProfiliUtente.pfuPassword)} = @Password" : "") } ";

            var queryParams = new DynamicParameters();
            queryParams.Add("@Login", username, direction: ParameterDirection.Input);
            if (!(password is null))
                queryParams.Add("@Password", password, direction: ParameterDirection.Input);

            return (sqlQuery, queryParams);
        }

        public ProfiliUtenteDTO GetAccountForLogin(string username, string password = null)
        {
            var (sqlQuery, queryParams) = BuildAccountForLoginQuery(username, password);
            var calcHash = CalcHashFuncFactory<ProfiliUtente, ProfiliUtenteDTO>();
            return Connection
                .Query<ProfiliUtente>(sqlQuery, queryParams)
                .Select(el => calcHash(el, true))
                .FirstOrDefault();
        }

        public async Task<ProfiliUtenteDTO> GetAccountForLoginAsync(string username, string password = null)
        {
            var (sqlQuery, queryParams) = BuildAccountForLoginQuery(username, password);
            var res = await Connection.QueryAsync<ProfiliUtente>(sqlQuery, queryParams);
            var calcHash = CalcHashFuncFactory<ProfiliUtente, ProfiliUtenteDTO>();
            return res.Select(el => calcHash(el, true)).FirstOrDefault();
        }

        public bool UpdateLastAccessDate(long accountId, string refreshToken, string tsIdToken = null)
        {
            var updateQuery = $@"
            UPDATE {typeof(ProfiliUtente).DbTableName()}
            SET {nameof(ProfiliUtente.pfuLastLogin)} = @UltimoAccesso,
                {nameof(ProfiliUtente.pfuRefreshToken)} = @RefreshToken
            {(!(tsIdToken is null) ? $", {nameof(ProfiliUtente.pfuToken)} = @TsIdToken" : "")}
            WHERE {nameof(ProfiliUtente.IdPfu)} = @AccountId ";

            var updateParameters = new DynamicParameters();
            updateParameters.Add("@UltimoAccesso", DateTime.UtcNow, direction: ParameterDirection.Input);
            updateParameters.Add("@RefreshToken", refreshToken, direction: ParameterDirection.Input);
            updateParameters.Add("@AccountId", accountId, direction: ParameterDirection.Input);
            if (!(tsIdToken is null))
                updateParameters.Add("@TsIdToken", tsIdToken, direction: ParameterDirection.Input);

            return Connection.Execute(updateQuery, updateParameters) == 1;
        }

        public ProfiliUtenteDTO Get(long id)
        {
            var sqlQuery = $@"
            Select *
            From {typeof(ProfiliUtente).DbTableName()} an03
            Where
                an03.{nameof(ProfiliUtente.IdPfu)} = @Id ";

            var calcHash = CalcHashFuncFactory<ProfiliUtente, ProfiliUtenteDTO>();

            return Connection
                .Query<ProfiliUtente>(sqlQuery, new { Id = id })
                .Select(el => calcHash(el, true))
                .FirstOrDefault();
        }
    }
}
