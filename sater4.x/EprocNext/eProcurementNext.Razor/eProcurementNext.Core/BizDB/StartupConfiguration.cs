using Microsoft.Extensions.DependencyInjection;

namespace eProcurementNext.BizDB
{

    public static partial class ServiceCollectionExtensions
    {

        public static IServiceCollection AddBizDB(this IServiceCollection services)
        {
            //services.AddTransient<ILibDbFunctions, LibDbFunctions>();
            services.AddTransient<iLib_dbFunctions, Lib_dbFunctions>();
            services.AddTransient<ILibDbMultilanguage, LibDbMultiLanguage>();
            services.AddTransient<ITabManage, TabManage>();
            services.AddTransient<IBlackList, BlackList>();

            return services;
        }
    }

}
