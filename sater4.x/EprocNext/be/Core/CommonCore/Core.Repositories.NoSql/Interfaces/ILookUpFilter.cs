using Core.Repositories.NoSql.Model;
using System;
using System.Collections.Generic;
using System.Text;

namespace Core.Repositories.NoSql.Interfaces
{
    public interface ILookUpFilter: ILookUpNoSqlFilter
    {
        string[] FieldsToInclude { get; set; }
        bool isFiltered { get; }
    }
}
