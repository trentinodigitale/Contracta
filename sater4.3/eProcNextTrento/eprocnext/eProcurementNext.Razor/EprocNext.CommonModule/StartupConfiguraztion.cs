using Microsoft.Extensions.DependencyInjection;

namespace eProcurementNext.CommonModule
{
    public static partial class ServiceCollectionExtensions
    {
        public static IServiceCollection AddEProcResponse(this IServiceCollection services)
        {
            services.AddTransient<IEprocResponse, EprocResponse>();
            return services;
        }
    }
}