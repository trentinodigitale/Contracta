using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using System;
using Core.DistribuitedCache.Manager;
using Core.DistribuitedCache.Interfaces;

namespace Core.DistribuitedCache
{
    public static partial class ServiceCollectionExtensions
    {
        public static IServiceCollection AddRedisCache(this IServiceCollection services, IConfiguration Configuration)
        {
            var redisConnection = Configuration.GetConnectionString("Redis");
            if (redisConnection is null)
                throw new Exception("Redis connection string not found in configuration file!");

            services.AddStackExchangeRedisCache(option =>
            {
                option.Configuration = redisConnection;
            });

            services.AddTransient<IDistributedCacheManager, DistributedCacheManager>();

            return services;
        }
    }
}
