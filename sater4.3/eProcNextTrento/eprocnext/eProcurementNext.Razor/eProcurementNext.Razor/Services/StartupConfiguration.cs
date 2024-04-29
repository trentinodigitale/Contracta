using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace eProcurementNext.Razor
{
    public static partial class StartupConfiguration
    {
        public static IServiceCollection AddResponseService(this IServiceCollection services)
        {
            services.AddTransient<IResponseService, ResponseService>();
            services.AddTransient<IMenuService, MenuService>();
            return services;
        }
    }
}
