using Core.Authentication.Auth;
using Core.Authentication.Interfaces;
using Core.Common.Constants.Authentication;
using Core.Authentication.Types;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;
using System.Security.Claims;
using System.Threading.Tasks;
using System;
using Core.Cryptography;

namespace Core.Authentication
{
    public static class StartupConfiguration
    {
        public static IServiceCollection AddAuthServices<TClaimsProvider>(this IServiceCollection services, IConfiguration configuration) where TClaimsProvider: class, IUserClaimsIdentityProvider
        {
            services
                .Configure<JwtGenerationSettings>(option => configuration.GetSection(nameof(JwtGenerationSettings)).Bind(option))
                .AddCryptoUtilsService()
                .AddTransient<IJWTTokenValidator, JWTTokenValidator>()
                .AddTransient<IUserClaimsIdentityProvider, TClaimsProvider>()
                .AddTransient<IAuthTokenGenerator, AuthTokenGenerator>()
                .AddTransient<ILoginManager, LoginManager>();

            return services;
        }

        public static IServiceCollection AddJwtBearer(this IServiceCollection services, IConfiguration configuration)
        {
            services.AddAuthentication(opts =>
            {
                opts.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                opts.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
            })
            .AddJwtBearer(opts =>
            {
                opts.RequireHttpsMetadata = false;
                opts.SaveToken = true;
                opts.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    ValidateIssuer = false,
                    ValidateAudience = false,
                    ValidateLifetime = true,
                    ClockSkew = TimeSpan.FromSeconds(30),
                    IssuerSigningKey = new SymmetricSecurityKey(JWTTokenConstants.IssuerSigningKey),
                    ValidIssuer = configuration.GetValue<string>("JwtGenerationSettings:JwtBearer:ValidIssuer"), 
                    ValidAudience = configuration.GetValue<string>("JwtGenerationSettings:JwtBearer:ValidAudience") 
                };
                opts.Events = new JwtBearerEvents
                {
                    OnMessageReceived = context =>
                    {
                        var accessToken = context.Request.Query["access_token"];
                        if (!string.IsNullOrEmpty(accessToken))
                            context.Token = accessToken;
                        return Task.CompletedTask;
                    }
                };
            });

            services.AddAuthorization(options =>
            {
                options.AddPolicy(JwtBearerDefaults.AuthenticationScheme, policy =>
                {
                    policy.AddAuthenticationSchemes(JwtBearerDefaults.AuthenticationScheme);
                    policy.RequireClaim(ClaimTypes.NameIdentifier);
                });
            });

            return services;
        }
    }
}
