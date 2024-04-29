using System;
using System.Collections.Generic;
using System.Text;

namespace Core.Repositories.NoSql.Interfaces
{
    public interface INoSqlSessionProvider
    {
        long TenantId { get; }
        long AccountId { get; }
        string SecretHashKey { get; }
        string CurrentUser { get; }
    }
}
