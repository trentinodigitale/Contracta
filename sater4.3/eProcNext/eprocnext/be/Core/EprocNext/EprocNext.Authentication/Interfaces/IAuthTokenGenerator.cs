using Core.Authentication.Types;
using System.Security.Claims;

namespace Core.Authentication.Interfaces
{
    public interface IAuthTokenGenerator
    {
        (string jwtToken, RefreshToken refreshToken) GenerateAuthTokens(ClaimsIdentity claims, bool neverExpire = false);
    }
}
