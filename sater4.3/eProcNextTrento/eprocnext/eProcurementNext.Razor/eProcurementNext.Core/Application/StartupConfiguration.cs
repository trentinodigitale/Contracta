using Microsoft.Extensions.DependencyInjection;

namespace eProcurementNext.Application
{
    public static partial class StartupConfiguration
    {
        public static IServiceCollection AddApplication(this IServiceCollection services)
        {
            services.AddSingleton<IEprocNextApplication, eProcNextApplication>();
            return services;
        }
    }
}
