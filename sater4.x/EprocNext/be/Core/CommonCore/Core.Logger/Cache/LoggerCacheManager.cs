using Core.Logger.Interfaces;
using Microsoft.Extensions.Caching.Distributed;
using System;
using System.Text.Json;

namespace Core.Logger.Cache
{
    internal class LoggerCacheManager : ILoggerCache
    {
        private IDistributedCache Cache { get; }

        public LoggerCacheManager(IDistributedCache cache)
        {
            Cache = cache;
        }

        private DistributedCacheEntryOptions GetSetOptions()
        {
            var Options = new DistributedCacheEntryOptions();
            Options.SetAbsoluteExpiration(DateTimeOffset.Now.AddHours(2));
            Options.SetSlidingExpiration(TimeSpan.FromMinutes(20));
            return Options;
        }

        public void SetValue<T>(string key, T value) where T : class
        {
            string jsonData = JsonSerializer.Serialize(value);
            Cache.SetString(key, jsonData, GetSetOptions());
        }

        public void SetValue(string key, string value)
        {
            Cache.SetString(key, value, GetSetOptions());
        }

        public T GetValue<T>(string key) where T : class
        {
            var value = Cache.GetString(key);
            if (value is null)
                return null;

            Cache.Refresh(key);
            return JsonSerializer.Deserialize<T>(value, new JsonSerializerOptions()
            {
                PropertyNameCaseInsensitive = true
            });
        }

        public string GetValue(string key)
        {
            return Cache.GetString(key);
        }
    }
}