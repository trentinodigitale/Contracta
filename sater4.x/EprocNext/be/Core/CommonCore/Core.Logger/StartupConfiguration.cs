using Core.Logger.Cache;
using Core.Logger.EventHub;
using Core.Logger.HelkLogEntry.Types;
using Core.Logger.Interfaces;
using Core.Logger.Logger;
using Core.Logger.Middleware;
using Core.Logger.NoSql;
using Core.Logger.Sql;
using Core.Logger.Types;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using System;

namespace Core.Logger
{
    public static class StartupConfiguration
    {
        public static IServiceCollection AddHelkLogger(this IServiceCollection services, IConfiguration configuration)
        {
            var redisConnection = configuration.GetConnectionString("Redis");
            if (redisConnection is null)
                throw new Exception("HELK Logger uses Redis cache for store user details, please specify a valid cache connection string!");

            try
            {
                services.AddStackExchangeRedisCache(option => option.Configuration = redisConnection);
                services.AddHttpContextAccessor();
            }
            catch { }

            services
                .Configure<LogMongoDB>(option => configuration.GetSection(nameof(LogMongoDB)).Bind(option))
                .Configure<ApplicationInfo>(option => configuration.GetSection(nameof(ApplicationInfo)).Bind(option))
                .Configure<HostInfo>(option => configuration.GetSection(nameof(HostInfo)).Bind(option))
                .Configure<CloudInfo>(option => configuration.GetSection(nameof(CloudInfo)).Bind(option))
                .Configure<LoggerConfiguration>(option => configuration.GetSection(nameof(LoggerConfiguration)).Bind(option))
                .AddTransient<ILoggerConfigurationProvider, LoggerConfigurationProvider>()
                .AddTransient<ILoggerCache, LoggerCacheManager>()
                .AddTransient<ISqlUserInfo, SqlUserInfoRepository>()
                .AddTransient<ILoggerMongoDBContext, LoggerMongoDBContext>()
                .AddTransient<IEventHubClient, EventHubClient>()
                .AddTransient<IHelkLogger, CustomHelkLogger>();

            return services;
        }
        public static IApplicationBuilder UseRequestTimestamp(this IApplicationBuilder builder)
        {
            return builder.UseMiddleware<ResponseTimeMiddleware>();
        }
    }
}
