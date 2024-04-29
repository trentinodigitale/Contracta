using EprocNext.Repositories.Interfaces;
using EprocNext.Repositories.Models;
using Core.DistribuitedCache.Interfaces;
using Core.Repositories.Abstractions.AbstractClasses;

namespace EprocNext.Repositories.Querying
{
    /// <summary>
    /// This is the Querying implementation with Cache-aside pattern of given Repository
    /// </summary>
    public partial class AziendeQuerying: AbsCachedRepository<IAziendeRepository, AziendeDTO>, IAziendeQuerying
    {
        public AziendeQuerying(IAziendeRepository repository, IDistributedCacheManager cache) : base(repository, cache)
        {
        }

        // You can override here basic Querying implementation
        // Or add new methods based on extended IAn01AziendeQuerying interface
    }
}
