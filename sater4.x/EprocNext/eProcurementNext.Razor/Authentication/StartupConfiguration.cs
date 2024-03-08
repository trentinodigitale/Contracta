using Microsoft.Extensions.DependencyInjection;

namespace eProcurementNext.Authentication
{
    public static partial class ServiceCollectionExtensions
    {
        public static IServiceCollection AddAuthenticationJWT(this IServiceCollection services)
        {
            services.AddTransient<IEprocNextAuthentication, JWT>();
            return services;
        }
    }
}
