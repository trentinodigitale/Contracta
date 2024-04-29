using Core.Repositories.NoSql.Data;
using Core.Repositories.NoSql.Interfaces;
using Core.Repositories.NoSql.Querying;
using Core.Repositories.NoSql.Types;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using MongoDB.Bson.Serialization.Conventions;

namespace Core.Repositories.NoSql
{
    public static class StartupConfiguration
    {
        public static IServiceCollection AddNoSqlRepository<SessionProvider>(this IServiceCollection services, IConfiguration configuration) where SessionProvider : class, INoSqlSessionProvider
        {
            var pack = new ConventionPack
            {
                new CustomCamelCaseElementNameConvention()
            };
            ConventionRegistry.Register("CamelCase", pack, _ => true);

            services
                .Configure<MongoConnection>(option => configuration.GetSection(nameof(MongoConnection)).Bind(option))
                .AddHttpContextAccessor()
                .AddTransient<INoSqlSessionProvider, SessionProvider>()
                .AddTransient(typeof(IPipelineQuerying<,>), typeof(PipelineQuerying<,>))
                .AddTransient(typeof(INoSqlDBContext<>), typeof(NoSqlDBContext<>));

            return services;
        }
    }
}
