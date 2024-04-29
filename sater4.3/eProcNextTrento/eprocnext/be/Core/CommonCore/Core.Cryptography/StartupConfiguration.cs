using Core.Authentication.Interfaces;
using Core.Authentication.Types;
using Microsoft.Extensions.DependencyInjection;

namespace Core.Cryptography
{
    public static class StartupConfiguration
    {
        public static IServiceCollection AddCryptoUtilsService(this IServiceCollection services)
        {
            services
                .AddTransient<ICryptoUtils, CryptoUtils>();
            return services;
        }
    }
}
