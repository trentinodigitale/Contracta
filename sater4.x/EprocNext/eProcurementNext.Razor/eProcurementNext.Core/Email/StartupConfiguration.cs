using eProcurementNext.Email;
using Microsoft.Extensions.DependencyInjection;

namespace eProcurementNext.Security
{
    public static partial class StartupConfiguration
    {
        public static IServiceCollection AddEmail(this IServiceCollection services)
        {
            services.AddTransient<ICr, Cr>();
            return services;
        }
    }
}
