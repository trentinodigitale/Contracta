using Core.Repositories.Interfaces;

namespace Core.Repositories.Abstractions.AbstractClasses
{
    public abstract class AbsQueryingFilter : IQueryingFilter
    {
        public virtual long Tenant { get; set; }
        public virtual bool ForceRefresh { get; set; }
        public virtual ICachingExpirationTime CachingExpirationTime { get; set; }
        public abstract string Query { get; }
        public abstract object Params { get; }
        public abstract string CacheKey { get; }
    }
}
