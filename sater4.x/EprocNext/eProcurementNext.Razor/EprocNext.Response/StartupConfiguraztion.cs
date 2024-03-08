using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

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