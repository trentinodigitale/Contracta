using Core.DistribuitedCache.Interfaces;
using Microsoft.Extensions.Caching.Distributed;
using System.Threading.Tasks;

namespace Core.DistribuitedCache.Manager
{
    public class DistributedCacheManager : IDistributedCacheManager
    {
        private IDistributedCache Cache { get; }

        public DistributedCacheManager(IDistributedCache cache)
        {
            Cache = cache;
        }

        public void Execute<TCommand>(TCommand command) where TCommand : ICommand<IDistributedCache>
        {
            command.Execute(Cache);
        }

        public async Task ExecuteAsync<TCommand>(TCommand command) where TCommand : ICommandAsync<IDistributedCache>
        {
            await command.ExecuteAsync(Cache);
        }
    }
}
