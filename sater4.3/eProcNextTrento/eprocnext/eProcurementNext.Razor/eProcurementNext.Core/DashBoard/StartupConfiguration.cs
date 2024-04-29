using Microsoft.Extensions.DependencyInjection;

namespace eProcurementNext.DashBoard
{

    public static partial class ServiceCollectionExtensions
    {
        public static IServiceCollection AddDashboard(this IServiceCollection services)
        {
            //services.AddTransient<IGRFunz, GRFunz>();
            services.AddTransient<IViewer, Viewer>();
            return services;
        }
    }

}
