using System.Security.Claims;

namespace eProcurementNext.Authentication
{
    public interface IEprocNextAuthentication
    {

        string GenerateToken(List<Claim>? listOfClaims = null);
        bool ValidateCurrentToken(string token, bool isProd);
        //string? GetClaim(string token, string claimType);
        string? RefreshToken(string token, int userId);
    }
}
