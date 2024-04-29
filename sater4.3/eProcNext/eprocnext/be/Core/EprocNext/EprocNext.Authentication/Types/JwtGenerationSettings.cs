namespace Core.Authentication.Types
{
    public class JwtBearer
    {
        public string ValidIssuer { get; set; }
        public string ValidAudience { get; set; }
    }

    public class JwtGenerationSettings
    {
        /// <summary>
        /// Contains the string for Valid Issuer and
        /// Valid Audience for creating JWT tokens
        /// </summary>
        public JwtBearer JwtBearer { get; set; }

        /// <summary>
        /// Duration time (in minutes) for JWT token.
        /// The Token expires after this minutes from creation.
        /// </summary>
        /// <value>10, 20, 30, 40</value>
        public double JwtTokenDuration { get; set; } = 20;

        /// <summary>
        /// Duration time (in minutes) for Refresh token generated
        /// together with Jwt Token.
        /// The Token expires after this minutes from creation.
        /// NOTE: this value should be GREATER than JwtTokenDuration
        /// </summary>
        /// <value>20, 30, 40, 50</value>
        public double RefreshTokenDuration { get; set; } = 35;

        /// <summary>
        /// If set to true the Refresh process ignore the expiration
        /// of refresh token.
        /// </summary>
        public bool BypassRefreshTokenExpiration { get; set; } = false;
    }

    public static class JwtConfigurationExtension
    {
        public static double GetRefreshTokenDuration(this JwtGenerationSettings settings)
        {
            if (settings.RefreshTokenDuration > settings.JwtTokenDuration)
                return settings.RefreshTokenDuration;
            return settings.JwtTokenDuration + 5;
        }
    }
}
