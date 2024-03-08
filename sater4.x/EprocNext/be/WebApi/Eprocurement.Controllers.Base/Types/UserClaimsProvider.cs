using Core.Common.Constants.Authentication;
using Core.Controllers.Types;
using Core.DTO.Common;
using EprocNext.Controllers.Base.Interfaces;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;

namespace EprocNext.Controllers.Base.Types
{
    public class UserClaimsProvider : IUserClaimProvider
    {
        protected IEnumerable<Claim> CurrentHttpContextClaims { get; }

        public DecodedUserClaims Claims => new DecodedUserClaims
        {
            Name = CurrentHttpContextClaims.First(x => x.Type == BaseCustomClaims.Name).Value,
            Surname = CurrentHttpContextClaims.First(x => x.Type == BaseCustomClaims.Surname).Value,
            GivenName = CurrentHttpContextClaims.First(x => x.Type == BaseCustomClaims.GivenName).Value,
            NameIdentifier = Convert.ToInt64(CurrentHttpContextClaims.First(x => x.Type == BaseCustomClaims.NameIdentifier).Value),
            TenantId = Convert.ToInt64(CurrentHttpContextClaims.First(x => x.Type == BaseCustomClaims.TenantId).Value),
            LoginTenantId = Convert.ToInt64(CurrentHttpContextClaims.First(x => x.Type == BaseCustomClaims.LoginTenantId).Value),
            IsPersonaGiuridica = CurrentHttpContextClaims.First(x => x.Type == BaseCustomClaims.IsPersonaGiuridica).Value,
            PartitaIva = CurrentHttpContextClaims.First(x => x.Type == BaseCustomClaims.PartitaIva).Value,
            Profile = CurrentHttpContextClaims.First(x => x.Type == BaseCustomClaims.Profile).Value,
            Role = CurrentHttpContextClaims.First(x => x.Type == BaseCustomClaims.Role).Value,
        };

        public UserClaimsProvider(IHttpContextAccessor httpContextAccessor)
        {
            CurrentHttpContextClaims = httpContextAccessor.HttpContext.User.Claims;
        }
    }
}
