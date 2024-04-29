using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using EprocNext.Repositories.Repositories;
using Microsoft.Extensions.DependencyInjection;
using AutoMapper;
using EprocNext.Repositories.Querying;
using EprocNext.Repositories.Models;
using EprocNext.Repositories.Interfaces;
using Core.Repositories.Interfaces;
using RepoDb;

namespace EprocNext.Repositories
{
    public static class EProcNextRepositoriesServiceCollectionExtensions
    {
        public static IServiceCollection AddEprocNextRepositories<TSessionProvider>(this IServiceCollection services, IEnumerable<Assembly> assemblyMapListToRegisterForDI = null, bool registerMaps = true) where TSessionProvider: class, ISqlSessionProvider
        {
            SqlServerBootstrap.Initialize();
            return EprocNextRepositories.AddEprocNextRepositories<TSessionProvider>(services, assemblyMapListToRegisterForDI, registerMaps);
        }

        public static IEnumerable<Assembly> GetEpcorNextRepositoriesMappingList(this IServiceCollection services)
        {
            var assemblies = new List<Assembly>
            {
                typeof(AziendeDTOMap).Assembly,
                typeof(ProfiliUtenteDTOMap).Assembly,

                // CUSTOM MAPPING
                
            };

            return assemblies.Distinct();
        }
    }

    public static class EprocNextRepositories
    {
        public static IServiceCollection AddEprocNextRepositories<TSessionProvider>(IServiceCollection services,
            IEnumerable<Assembly> assemblyMapListToRegisterForDI = null, bool registerMaps = true) where TSessionProvider : class, ISqlSessionProvider
        {
            services.AddTransient<ISqlSessionProvider, TSessionProvider>();
            services.AddTransient(typeof(IAziendeRepository), typeof(AziendeRepository));
            services.AddTransient(typeof(IAziendeQuerying), typeof(AziendeQuerying));
            services.AddTransient(typeof(IProfiliUtenteRepository), typeof(ProfiliUtenteRepository));
            services.AddTransient(typeof(IAziendeQuerying), typeof(AziendeQuerying));

            if (registerMaps)
            {
                var coreMaps = services.GetEpcorNextRepositoriesMappingList();
                var mapListToRegister = assemblyMapListToRegisterForDI != null
                    ? coreMaps.Distinct().Union(assemblyMapListToRegisterForDI)
                    : coreMaps.Distinct();
                services.AddAutoMapper(mapListToRegister, ServiceLifetime.Singleton);
            }

            return services;
        }
    }
}
