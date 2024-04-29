using Core.Logger.HelkLogEntry.Types;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace Core.Logger.Interfaces
{
    public interface IHelkLogger
    {
        /// <summary>
        /// Retrieve the actual loaded configuration used
        /// for logging
        /// </summary>
        ILoggerConfiguration Configuration { get; }

        /// <summary>
        /// Stats log function, use this for logging data
        /// for statistical use.
        /// </summary>
        /// <param name="statsData">user, event data, significant event information</param>
        void Stat<T>(ILogEntryData<T> statsData) where T: class;

        /// <summary>
        /// Generic Log function, use this for standard logging
        /// of generic event inside the application
        /// </summary>
        /// <param name="entryData">user, event data, with log level and exception information</param>
        void Log<T>(ILogEntryData<T> entryData) where T : class;

        /// <summary>
        /// Stats log function, use this for logging data
        /// for statistical use.
        /// </summary>
        /// <param name="statsData">user, event data, significant event information</param>
        Task StatAsync<T>(ILogEntryData<T> statsData) where T : class;

        /// <summary>
        /// Generic Log function, use this for standard logging
        /// of generic event inside the application
        /// </summary>
        /// <param name="entryData">user, event data, with log level and exception information</param>
        Task LogAsync<T>(ILogEntryData<T> entryData) where T : class;
    }
}
