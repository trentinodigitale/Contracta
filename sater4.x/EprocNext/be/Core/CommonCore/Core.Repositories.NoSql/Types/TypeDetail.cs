using System;
using System.Collections.Generic;
using System.Text;

namespace Core.Repositories.NoSql.Data
{
    public class TypeDetail
    {
        public string Name { get; set; }
        public string FullName { get; set; }
        public string TypeName { get; set; }
        public string TypeFullName { get; set; }
        public Type PType { get; set; }
        public bool IsPrimitive { get; set; }
    }
}
