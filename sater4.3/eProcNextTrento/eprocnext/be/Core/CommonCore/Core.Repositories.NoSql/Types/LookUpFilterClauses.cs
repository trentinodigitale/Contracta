using Core.Repositories.NoSql.Interfaces;
using Core.Repositories.Types;
using System;

namespace Core.Repositories.NoSql.Model
{
    public class LookUpFilterClauses : ILookUpFilterClauses
    {
        public string ColumnName { get; set; }
        public string Value { get; set; }
        public LookupFilterOperation Operation { get; set; }
        public DateTime? dateFrom { get; set; }
        public DateTime? dateTo { get; set; }
    }
}
