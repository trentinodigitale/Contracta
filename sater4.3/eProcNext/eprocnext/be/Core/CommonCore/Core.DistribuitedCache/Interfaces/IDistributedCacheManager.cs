using Microsoft.Extensions.Caching.Distributed;

namespace Core.DistribuitedCache.Interfaces
{
    public interface IDistributedCacheManager : ICommandInvoker<IDistributedCache>, ICommandInvokerAsync<IDistributedCache>
    { }
}
