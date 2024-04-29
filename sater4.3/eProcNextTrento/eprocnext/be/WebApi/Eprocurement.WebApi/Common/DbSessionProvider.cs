using Core.Common.Constants.Authentication;
using Core.Repositories.Interfaces;
using Core.Repositories.NoSql.Interfaces;
using Microsoft.AspNetCore.Http;
using System;
using System.Linq;

namespace EprocNext.Repositories
{
    public class DbSessionProvider : ISqlSessionProvider, INoSqlSessionProvider
    {
        public DbSessionProvider(IHttpContextAccessor httpContextAccessor)
        {
            try
            {
                var claims = httpContextAccessor?.HttpContext?.User?.Claims;
                TenantId = Convert.ToInt64(claims.FirstOrDefault(x => x.Type == BaseCustomClaims.TenantId)?.Value ?? "0");
                AccountId = Convert.ToInt64(claims.FirstOrDefault(x => x.Type == BaseCustomClaims.NameIdentifier)?.Value ?? "0");
                CurrentUser = claims?.FirstOrDefault(x => x.Type == BaseCustomClaims.Name)?.Value ?? "";
            }
            catch
            {
                TenantId = 0;
                AccountId = 0;
                CurrentUser = "";
            }
        }

        public long TenantId { get; }
        public long AccountId { get; }
        public string CurrentUser { get; }
        public string SecretHashKey { get; } = "Sup35Sec3e_T";
    }
}
