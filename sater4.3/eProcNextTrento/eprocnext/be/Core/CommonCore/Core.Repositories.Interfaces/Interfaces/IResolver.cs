using Core.Repositories.Abstractions.Interfaces;
using System;
using System.Collections.Generic;
using System.Text;

namespace Core.Repositories.Interfaces
{
    public interface IResolver
    {
        string FieldResolver(string fieldName);
    }

    public interface IDtoResolver
    {
        Type Resolver { get; }
    }

    public interface IClauseNormalizer
    {
        void AddResolver(IResolver resolver);

        string NormalizeFrom<TDto>(string whereCondition) where TDto : IDtoResolver, ISecurityDTO, new();
        string NormalizeLookUpFilter(IEnumerable<ILookupFilterDTO> lookupFilter, ref IDictionary<string, object> parameters);
        string NormalizeLookUpOrderBy(IEnumerable<ILookupSortingDTO> lookupSorting);
        string NormalizeWhere(string dtoWhereCondition);

        string NormalizeorderBy(string orderByCondition);

        string CreateBaseSelect<TDto>();

        IDictionary<string, object> MergeAnonimousQueryParameters(object params1, object params2);
        void MergeAnonimousQueryParametersFromDictory(ref IDictionary<string, object> dynamicParam, object params2);

        string NormalizeJoin(string sqlWithJoin);

        void BuildInsertParameters<T>(StringBuilder sb);
        void BuildInsertValues<T>(StringBuilder sb, T entity);
        void BuildUpdateParametersAndValues<T>(StringBuilder sb, T entity);
    }
}
