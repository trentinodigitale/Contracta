using Core.Repositories.Types;
using System;
using System.Collections.Generic;
using System.Text;

namespace Core.Repositories.NoSql.Interfaces
{
    public interface ILookUpFilterClauses
    {
        string ColumnName { get; set; }
        string Value { get; set; }
        LookupFilterOperation Operation { get; set; }
        DateTime? dateFrom { get; set; }
        DateTime? dateTo { get; set; }
    }
}
