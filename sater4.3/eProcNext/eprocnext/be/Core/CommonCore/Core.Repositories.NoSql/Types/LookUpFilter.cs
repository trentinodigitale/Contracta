using Core.Repositories.NoSql.Interfaces;

namespace Core.Repositories.NoSql.Model
{
    public class LookUpFilter : ILookUpFilter
    {
        public int PageNumber { get; set; } = 1;
        public int PageSize { get; set; } = 5;
        public LookUpFilterClauses[] Filters { get; set; } = new LookUpFilterClauses[0];
        public LookUpOrderBy[] Sorting { get; set; } = null;
        public bool isFiltered => (Filters == null) ? false : Filters.Length > 0;
        public bool isOrdered => Sorting != null;

        /// <summary>
        /// Contains fields list to include in the result.
        /// If It'll set, the result will have only the fields specified here.
        /// Example:
        /// To filter only two field in a document: {_id: 'xxx', field1: 'data', container: { field2: 'data', ...}, ...}
        /// You must use list like this ["field1", "container.field2"]
        /// </summary>
        public string[] FieldsToInclude { get; set; } = new string[0];
    }
}
