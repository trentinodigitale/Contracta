using Core.Repositories.Types;
using System;
using System.Collections.Generic;
using System.Text;

namespace Core.Repositories.NoSql.Interfaces
{
    public interface ILookUpOrderBy
    {
        string ColumnName { get; set; }
        LookupSortingDirection Direction { get; set; }
    }
}
