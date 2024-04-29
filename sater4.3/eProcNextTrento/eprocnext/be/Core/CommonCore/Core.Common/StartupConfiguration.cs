using Cloud.Core.Common.Helpers;
using Cloud.Core.Common.Interfaces;
using Microsoft.Extensions.DependencyInjection;

namespace Cloud.Core.Common
{
    public static class StartupConfiguration
    {
        public static IServiceCollection AddObjectComparerService(this IServiceCollection services)
        {
            services.AddTransient<IObjectComparer, ObjectComparer>();
            return services;
        }

        public static IServiceCollection AddObjectComparerRules<TRules, TCompare>(this IServiceCollection services) where TRules: class, IComparerRules<TCompare>
        {
            services.AddTransient<IComparerRules<TCompare>, TRules>();
            return services;
        }

        public static IServiceCollection AddObjectComparerRules<TRules, TCompare1, TCompare2>(this IServiceCollection services) where TRules : class, IComparerRules<TCompare1, TCompare2>
        {
            services.AddTransient<IComparerRules<TCompare1, TCompare2>, TRules>();
            return services;
        }
    }
}
