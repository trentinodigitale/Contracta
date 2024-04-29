using EprocNext.Repositories.Models;
using System.Security.Claims;

namespace Core.Authentication.Interfaces
{
    public interface IUserClaimsIdentityProvider
    {
        ClaimsIdentity GetClaimsIdentity(ProfiliUtenteDTO account, long? workingTenant = null);
    }
}
