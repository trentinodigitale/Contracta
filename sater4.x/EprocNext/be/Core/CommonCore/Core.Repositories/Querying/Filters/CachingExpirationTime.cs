using Core.Repositories.Interfaces;
using System;
using System.Collections.Generic;
using System.Text;

namespace Core.Repositories.Querying.Filters
{
    /// <summary>
    /// Specify the caching expiration time for Querying cached repository
    /// </summary>
    public class CachingExpirationTime : ICachingExpirationTime
    {
        /// <summary>
        /// Set Absolute expiration time in MINUTES
        /// </summary>
        public int? AbsoluteExpiringTime { get; set; }

        /// <summary>
        /// Set Sliding expiration time in MINUTES
        /// </summary>
        public int? SlidingExpiringTime { get; set; }
    }
}
