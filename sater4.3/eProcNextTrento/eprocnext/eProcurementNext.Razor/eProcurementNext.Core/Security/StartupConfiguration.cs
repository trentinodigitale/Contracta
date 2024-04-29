using Microsoft.Extensions.DependencyInjection;

namespace eProcurementNext.Security
{
    public static partial class StartupConfiguration
    {
        public static IServiceCollection AddSecurity(this IServiceCollection services)
        {
            services.AddTransient<IValidation, Validation>();
            return services;
        }
    }
}
