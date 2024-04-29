using System;
using System.Security.Cryptography;

namespace Core.Authentication.Types
{
    public class RefreshToken
    {
        public string Token { get; set; }
        public DateTime Expiration { get; set; }

        public RefreshToken()
        {

        }

        public RefreshToken(double durationMinute)
        {
            Token = GenerateRefreshToken();
            Expiration = DateTime.Now.AddMinutes(durationMinute);
        }

        private string GenerateRefreshToken()
        {
            var randomNumber = new byte[32];
            using var rng = RandomNumberGenerator.Create();
            rng.GetBytes(randomNumber);
            return Convert.ToBase64String(randomNumber);
        }
    }
}
