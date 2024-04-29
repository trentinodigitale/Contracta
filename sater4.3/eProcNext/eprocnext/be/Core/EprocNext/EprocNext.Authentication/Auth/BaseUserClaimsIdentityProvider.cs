using EprocNext.Repositories.Interfaces;
using EprocNext.Repositories.Models;
using Core.Authentication.Interfaces;
using Core.Common.Constants.Authentication;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;

namespace Core.Authentication.Auth
{
    public class BaseUserClaimsIdentityProvider : IUserClaimsIdentityProvider
    {
        IProfiliUtenteRepository ProfiliUtenteRep { get; }
        IHttpContextAccessor HttpContextAccessor { get; }

        public BaseUserClaimsIdentityProvider(IProfiliUtenteRepository profiliUtenteRep, IHttpContextAccessor contextAccessor)
        {
            ProfiliUtenteRep = profiliUtenteRep;
            HttpContextAccessor = contextAccessor;
        }

        private string GetLoginTenantFromHttpContext()
        {
            try
            {
                if (!HttpContextAccessor.HttpContext.User.Identity.IsAuthenticated)
                    return null;
                return null;
                //return HttpContextAccessor.HttpContext.User.FindFirst(BaseCustomClaims.LoginTenantId).Value;
            }
            catch { return null; }
        }

        public virtual ClaimsIdentity GetClaimsIdentity(ProfiliUtenteDTO account, long? workingTenant = null)
        {
            //var UtentiAziendaList = Utentiazienda.GetTenantRolesForUser(account.IdPfu);
            bool tenantFilter(Tuple<ProfiliUtenteDTO, AziendeDTO> x) => x.Item1.pfuIdAzi == workingTenant;
            //var utentiAzienda = workingTenant.HasValue && workingTenant > 0 ? UtentiAziendaList.FirstOrDefault(tenantFilter) : UtentiAziendaList.FirstOrDefault();
            //var an05UtentiAzienda = utentiAzienda.Item1;
            //var claims = new List<Claim>();
            var claims = new List<Claim>
            {
                new Claim(BaseCustomClaims.Name, account.pfuLogin),
                new Claim(BaseCustomClaims.Surname,account.pfuNome),
                new Claim(BaseCustomClaims.GivenName,account.pfuCognome),
                new Claim(BaseCustomClaims.NameIdentifier,account.IdPfu.ToString()),
                new Claim(BaseCustomClaims.Profile, account.pfuRuoloAziendale),
                new Claim(BaseCustomClaims.TenantId, account.pfuIdAzi.ToString()),
                new Claim(BaseCustomClaims.LoginTenantId, GetLoginTenantFromHttpContext() ?? account.pfuIdAzi.ToString()),
                //new Claim(BaseCustomClaims.IsPersonaGiuridica, (account != null && account.lgprsfis.HasValue) ? account.lgprsfis.Value == 1 ? "0" : "1" : ""),
                //new Claim(BaseCustomClaims.IsPersonaGiuridica, "0",
                //new Claim(BaseCustomClaims.PartitaIva, account?.Partiva ?? "")
            };

            claims.AddRange(account.pfuRuoloAziendale
                .Split(';')
                .Select(str => new Claim(ClaimTypes.Role, str))
                .ToList()
            );

            return new ClaimsIdentity(claims);
        }
    }
}
