using System;
using System.Collections.Generic;
using System.Text;

namespace Core.Repositories.NoSql.Interfaces
{
    public interface INoSqlTenantSecurityCollection : INoSqlCollection
    {
        long Tenant { get; set; }
        uint Hash { get; set; }
    }
}
