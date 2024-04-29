using Core.Common.Constants.Authentication;
using Core.Authentication.Interfaces;
using Core.Authentication.Types;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using System;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace Core.Authentication.Auth
{
    public class AuthTokenGenerator : IAuthTokenGenerator
    {
        JwtGenerationSettings Configuration { get; }

        public AuthTokenGenerator(IOptions<JwtGenerationSettings> configuration)
        {
            Configuration = configuration.Value;
        }

        public (string jwtToken, RefreshToken refreshToken) GenerateAuthTokens(ClaimsIdentity claims, bool neverExpire = false)
        {
            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = claims,
                NotBefore = DateTime.UtcNow,
                IssuedAt = DateTime.UtcNow,
                Expires = neverExpire ? DateTime.Now.AddYears(1000) : DateTime.Now.AddMinutes(Configuration.JwtTokenDuration),
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(JWTTokenConstants.IssuerSigningKey), SecurityAlgorithms.HmacSha256Signature),
                Audience = Configuration.JwtBearer.ValidAudience,
                Issuer = Configuration.JwtBearer.ValidIssuer
            };
            var tokenHandler = new JwtSecurityTokenHandler();
            var token = tokenHandler.CreateToken(tokenDescriptor);
            return (tokenHandler.WriteToken(token), new RefreshToken(Configuration.GetRefreshTokenDuration()));
        }
    }
}
