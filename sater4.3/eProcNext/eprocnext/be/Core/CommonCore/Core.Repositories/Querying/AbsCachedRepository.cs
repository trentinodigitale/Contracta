using Core.DistribuitedCache.Interfaces;
using Core.DistribuitedCache.Manager.Commands;
using Core.Repositories.Interfaces;
using Microsoft.Extensions.Caching.Distributed;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Core.Repositories.Abstractions.AbstractClasses
{
    public abstract class AbsCachedRepository<TRepo, TDto> : ICachedRepository<TDto>
        where TRepo : class, IRepositoryCrud<TDto>
        where TDto : class, IDtoResolver, ISecurityDTO, new()
    {
        protected IDistributedCacheManager Cache { get; }
        protected TRepo Repository { get; }

        public AbsCachedRepository(TRepo repository, IDistributedCacheManager redisCache)
        {
            Cache = redisCache;
            Repository = repository;
        }

        protected virtual DistributedCacheEntryOptions GetCacheOptions(ICachingExpirationTime cachingExpirationTime)
        {
            if (cachingExpirationTime is null)
                return null;

            var options = new DistributedCacheEntryOptions();

            if (cachingExpirationTime.AbsoluteExpiringTime.HasValue)
                options.SetAbsoluteExpiration(DateTimeOffset.Now.AddMinutes(cachingExpirationTime.AbsoluteExpiringTime.Value));

            if (cachingExpirationTime.SlidingExpiringTime.HasValue)
                options.SetSlidingExpiration(TimeSpan.FromMinutes(cachingExpirationTime.SlidingExpiringTime.Value));

            return options;
        }

        public virtual TDto GetCachedData<TFilter>(TFilter filter) where TFilter : class, IQueryingFilter
        {
            // 1. Search on Distributed Cache
            var cachedKey = filter.CacheKey;
            if (!filter.ForceRefresh)
            {
                var getCommand = new GetCommand<TDto>(cachedKey);
                Cache.Execute(getCommand);
                if (getCommand.Result != default(TDto))
                {
                    // An hit on Distributed cache, refresh data time to live and save on local cache
                    Cache.Execute(new RefreshCommand(cachedKey));
                    return getCommand.Result;
                }
            }

            // 2. If not found search on SQL DB, and return NULL if not found
            var result = Repository.GetList(filter.Tenant, filter.Query, filter.Params).FirstOrDefault();
            if (result == null)
                return null;

            // 3. Add it to cache and return the value
            Cache.Execute(new SetCommand<TDto>(cachedKey, result, GetCacheOptions(filter.CachingExpirationTime)));
            return result;
        }

        public virtual async Task<TDto> GetCachedDataAsync<TFilter>(TFilter filter) where TFilter : class, IQueryingFilter
        {
            // 1. Search on Distributed Cache
            var cachedKey = filter.CacheKey;
            if (!filter.ForceRefresh)
            {
                var getCommand = new GetCommand<TDto>(cachedKey);
                await Cache.ExecuteAsync(getCommand);
                if (getCommand.Result != null)
                {
                    // An hit on Distributed cache, refresh data time to live and save on local cache
                    await Cache.ExecuteAsync(new RefreshCommand(cachedKey));
                    return getCommand.Result;
                }
            }

            // 2. If not found search on SQL DB, and return NULL if not found
            var result = (await Repository.GetListAsync(filter.Tenant, filter.Query, filter.Params)).FirstOrDefault();
            if (result == null)
                return null;

            // 3. Add it to cache and return the value
            await Cache.ExecuteAsync(new SetCommand<TDto>(cachedKey, result, GetCacheOptions(filter.CachingExpirationTime)));
            return result;
        }

        public virtual IEnumerable<TDto> GetCachedList<TFilter>(TFilter filter) where TFilter : class, IQueryingFilter
        {
            // 1. Search on Distributed Cache
            var cachedKey = filter.CacheKey;
            if (!filter.ForceRefresh)
            {
                var getCommand = new GetCommand<IEnumerable<TDto>>(cachedKey);
                Cache.Execute(getCommand);
                if (getCommand.Result != null)
                {
                    // An hit on Distributed cache, refresh data time to live and save on local cache
                    Cache.Execute(new RefreshCommand(cachedKey));
                    return getCommand.Result;
                }
            }

            // 2. If not found search on SQL DB, and return NULL if not found
            var result = Repository.GetList(filter.Tenant, filter.Query, filter.Params);
            if (result == null)
                return null;

            // 3. Add it to cache and return the value
            Cache.Execute(new SetCommand<IEnumerable<TDto>>(cachedKey, result, GetCacheOptions(filter.CachingExpirationTime)));
            return result;
        }

        public virtual async Task<IEnumerable<TDto>> GetCachedListAsync<TFilter>(TFilter filter) where TFilter : class, IQueryingFilter
        {
            // 1. Search on Distributed Cache
            var cachedKey = filter.CacheKey;
            if (!filter.ForceRefresh)
            {
                var getCommand = new GetCommand<IEnumerable<TDto>>(cachedKey);
                await Cache.ExecuteAsync(getCommand);
                if (getCommand.Result != null)
                {
                    // An hit on Distributed cache, refresh data time to live and save on local cache
                    await Cache.ExecuteAsync(new RefreshCommand(cachedKey));
                    return getCommand.Result;
                }
            }

            // 2. If not found search on SQL DB, and return NULL if not found
            var result = await Repository.GetListAsync(filter.Tenant, filter.Query, filter.Params);
            if (result == null)
                return null;

            // 3. Add it to cache and return the value
            await Cache.ExecuteAsync(new SetCommand<IEnumerable<TDto>>(cachedKey, result, GetCacheOptions(filter.CachingExpirationTime)));
            return result;
        }
    }
}
