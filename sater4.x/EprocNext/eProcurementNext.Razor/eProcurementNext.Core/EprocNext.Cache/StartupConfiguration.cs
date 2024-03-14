using Microsoft.Extensions.DependencyInjection;

namespace eProcurementNext.Cache
{
    public static partial class ServiceCollectionExtensions
    {
        public static IServiceCollection AddCustomCache(this IServiceCollection services)
        {
            services.AddTransient<IEprocNextCache, EProcNextCache>();
            return services;
        }
    }
}
