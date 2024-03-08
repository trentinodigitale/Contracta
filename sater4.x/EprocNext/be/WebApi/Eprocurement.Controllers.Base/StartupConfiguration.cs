using Core.Authentication;
using Core.Authentication.Auth;
using EprocNext.Controllers.Base.Interfaces;
using EprocNext.Controllers.Base.Types;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Versioning;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace EprocNext.Controllers.Base
{
    public static class StartupConfiguration
    {
        public static IServiceCollection AddCoreServices(this IServiceCollection services, IConfiguration configuration)
        {
            // Add all services to perform Login
            services.AddAuthServices<BaseUserClaimsIdentityProvider>(configuration);

            // Add Jwt Bearer configuration for Authorization middleware
            services.AddJwtBearer(configuration);

            // Add claims decoder provider
            services.AddHttpContextAccessor();
            services.AddScoped<IUserClaimProvider, UserClaimsProvider>();

            // Add API version
            services.AddApiVersioning(o => {
                o.ReportApiVersions = true;
                o.DefaultApiVersion = new ApiVersion(1, 0);
                o.AssumeDefaultVersionWhenUnspecified = true;
                o.ApiVersionReader = ApiVersionReader.Combine(new HeaderApiVersionReader("X-version"), new QueryStringApiVersionReader("api-version"));
            });

            return services;
        }
    }
}
