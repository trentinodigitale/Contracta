using Core.Repositories.NoSql.Interfaces;
using System;
using System.Collections.Generic;
using System.Text;

namespace Core.Repositories.NoSql.Types
{
    class NoSqlLinqDynamicFilter : INoSqlLinqDynamicFilter
    {
        public string Where { get; set; }
        public string OrderBy { get; set; }
    }
}
