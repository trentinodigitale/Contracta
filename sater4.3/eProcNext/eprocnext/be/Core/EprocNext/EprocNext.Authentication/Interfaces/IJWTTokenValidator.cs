using System;
using System.Collections.Generic;
using System.Security.Claims;
using System.Text;

namespace Core.Authentication.Interfaces
{
    public interface IJWTTokenValidator
    {
        bool ValidateToken(string jwtToken, out ClaimsPrincipal claims);

        string GetClaim(string jwtToken, string claimName);
    }
}
