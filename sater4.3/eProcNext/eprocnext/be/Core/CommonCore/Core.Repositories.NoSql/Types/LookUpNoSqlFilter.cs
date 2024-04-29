using Core.Repositories.NoSql.Interfaces;

namespace Core.Repositories.NoSql.Model
{
    public class LookUpNoSqlFilter : ILookUpNoSqlFilter
    {
        public int PageNumber { get; set; } = 1;
        public int PageSize { get; set; } = 5;
        public LookUpFilterClauses[] Filters { get; set; } = new LookUpFilterClauses[0];
        public LookUpOrderBy[] Sorting { get; set; } = null;
    }
}
