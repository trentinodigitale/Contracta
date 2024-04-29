using Core.Repositories.NoSql.Interfaces;
using Core.Repositories.Types;

namespace Core.Repositories.NoSql.Model
{
    public class LookUpOrderBy : ILookUpOrderBy
    {
        public string ColumnName { get; set; }
        public LookupSortingDirection Direction { get; set; }
    }
}
