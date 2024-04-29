using Core.Common.Constants.Authentication;
using Core.Authentication.Interfaces;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Logging;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Security.Claims;
using System;

namespace Core.Authentication.Types
{
    public class JWTTokenValidator : IJWTTokenValidator
    {
        JwtGenerationSettings Configuration { get; }

        public JWTTokenValidator(IOptions<JwtGenerationSettings> configuration)
        {
            Configuration = configuration.Value;
        }

        public bool ValidateToken(string jwtToken, out ClaimsPrincipal claims)
        {
            IdentityModelEventSource.ShowPII = true;
            claims = null;

            var validationParameters = new TokenValidationParameters
            {
                ValidateLifetime = !Configuration.BypassRefreshTokenExpiration,
                ClockSkew = TimeSpan.FromMinutes(Configuration.GetRefreshTokenDuration() - Configuration.JwtTokenDuration),
                ValidAudience = Configuration.JwtBearer.ValidAudience.ToLower(),
                ValidIssuer = Configuration.JwtBearer.ValidIssuer.ToLower(),
                IssuerSigningKey = new SymmetricSecurityKey(JWTTokenConstants.IssuerSigningKey)
            };

            try
            {
                claims = new JwtSecurityTokenHandler().ValidateToken(jwtToken, validationParameters, out SecurityToken validatedToken);
                if (validatedToken == null && !claims.Claims.Any())
                    return false;
            }
            catch (SecurityTokenException ex)
            {
                Console.WriteLine(ex);
                return false;
            }

            return true;
        }

        public string GetClaim(string jwtToken, string claimName)
        {
            if (!ValidateToken(jwtToken, out var claims))
                return null;

            return claims?.FindFirstValue(claimName);
        }
    }
}
