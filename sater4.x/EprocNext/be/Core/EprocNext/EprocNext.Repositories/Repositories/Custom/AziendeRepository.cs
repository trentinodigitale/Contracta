using AutoMapper;
using Core.Repositories.Interfaces;
using EprocNext.Repositories.Interfaces;
using EprocNext.Repositories.Models;
using Microsoft.Extensions.Configuration;
using Core.Repositories.Repositories;

namespace EprocNext.Repositories.Repositories
{
    /// <summary>
    /// This is the Repository implementation of CRUD repository
    /// </summary>
    public partial class AziendeRepository: RepositoryCrud<AziendeDTO, Aziende, AziendeDTOMap>, IAziendeRepository
    {
        public AziendeRepository(IConfiguration config, ISqlSessionProvider session, IMapper map) : base(config, session, map)
        {
            BuildTenantWhereCondition = (long tenantId, string basicWhereCondition) =>
            {
                string tenantCheckCondition = $"WHERE {nameof(AziendeDTO.IdAzi)}=@IdAzi";
                string concatWhere = $"{(!string.IsNullOrWhiteSpace(basicWhereCondition) ? $" AND ( {basicWhereCondition} )" : "")}";
                return $"{tenantCheckCondition} {concatWhere}";
            };

            BuildTenantBaseParameters = (long tenantId, object parameters, IClauseNormalizer normalizer) =>
            {
                return normalizer.MergeAnonimousQueryParameters(new { TenantId = tenantId }, parameters);
            };
        }

        // You can override here basic CRUD implementation
        // Or add new methods based on extended IAn01AziendeRepository interface
    }
}
