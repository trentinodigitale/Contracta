using Core.Repositories.NoSql.Model;
using System;
using System.Collections.Generic;
using System.Text;

namespace Core.Repositories.NoSql.Interfaces
{
    public interface ILookUpNoSqlFilter
    {
        int PageNumber { get; set; }
        int PageSize { get; set; }
        LookUpFilterClauses[] Filters { get; set; }
        LookUpOrderBy[] Sorting { get; set; }
    }
}
