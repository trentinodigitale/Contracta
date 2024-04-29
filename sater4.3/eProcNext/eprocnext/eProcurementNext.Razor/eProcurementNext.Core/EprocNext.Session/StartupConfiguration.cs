using Microsoft.Extensions.DependencyInjection;

namespace eProcurementNext.Session
{

    public static partial class ServiceCollectionExtensions
    {
        public static IServiceCollection AddCustomSession(this IServiceCollection services)
        {
            services.AddTransient<ISession, Session>();
            return services;
        }
    }
}
