namespace Core.Repositories.Interfaces
{
    public interface ICachingExpirationTime
    {
        /// <summary>
        /// If has value it is used to set the absolute
        /// expiring time from Now to X minutes (where X
        /// is the value)
        /// </summary>
        int? AbsoluteExpiringTime { get; }

        /// <summary>
        /// If has value it is used to set the sliding
        /// expiring time from Now to X minutes (where X
        /// is the value)
        /// </summary>
        int? SlidingExpiringTime { get; }
    }

    public interface IQueryingFilter
    {
        /// <summary>
        /// Specify the Working Tenant for the GetList
        /// method from Repository object used inside the
        /// querying object.
        /// </summary>
        long Tenant { get; }

        /// <summary>
        /// Set to true to force refreshing data from
        /// Database (and then updating the data on cache)
        /// </summary>
        bool ForceRefresh { get; }

        /// <summary>
        /// Optional parameter for selecting expiration
        /// time values (if not set default caching options
        /// are used inside the command).
        /// </summary>
        ICachingExpirationTime CachingExpirationTime { get; }

        /// <summary>
        /// The key used to save (and retrive) data from
        /// Distributed cache
        /// </summary>
        string CacheKey { get; }

        /// <summary>
        /// The where condition used to retrive data from
        /// Database (uses as parameters in GetList repository
        /// method).
        /// </summary>
        string Query { get; }

        /// <summary>
        /// The object which contains the parameters value
        /// defined insider Query prop.
        /// </summary>
        object Params { get; }
    }
}
