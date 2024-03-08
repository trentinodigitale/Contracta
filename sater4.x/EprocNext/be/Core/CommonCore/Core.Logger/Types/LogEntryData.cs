using Core.Logger.Interfaces;
using Core.Logger.Types;
using System;
using System.Diagnostics;

namespace Cloud.Core.HelkLogger.Types
{
    /// <summary>
    /// Class for creating single log entry with HELK Logger
    /// system. Use as input for the method Log of HelkLogger
    /// class.
    /// </summary>
    public class LogEntryData<T> : ILogEntryData<T> where T: class
    {
        /// <summary>
        /// Log level (info - warning - ecc...).
        /// Mandatory props
        /// </summary>
        public LogLevel Level { get; set; }

        /// <summary>
        /// Log message, clear text (don't put documents or base64/binary data).
        /// Mandatory props
        /// </summary>
        public T Message { get; set; }

        /// <summary>
        /// Used only in HELK Logger platform, specify the retention period
        /// (in days) for this single log entry.
        /// </summary>
        /// <value>15 (default)</value>
        public int Retention { get; set; } = 15;

        /// <summary>
        /// Specify the application Area which originated this log entry.
        /// </summary>
        /// <value>enum ApplicationArea</value>
        public ApplicationArea ApplicationArea { get; set; } = ApplicationArea.Core;

        /// <summary>
        /// In case of Specific application area, implement the
        /// interface ISpecificApplicationArea and set the name
        /// of the specific area of your application (depending
        /// on your application business logic)
        /// </summary>
        public ISpecificApplicationArea SpecificApplicationArea { get; set; } = null;

        /// <summary>
        /// Generated Exception
        /// </summary>
        public Exception LogException { get; set; } = null;

        /// <summary>
        /// Serialized input data from the method caller.
        /// Optional.
        /// </summary>
        public string InputData { get; set; } = null;

        /// <summary>
        /// HTTP Response status code
        /// </summary>
        public int? ResponseStatusCode { get; set; } = null;

        /// <summary>
        /// High resolution timer started at the beginning of the
        /// method caller execution.
        /// </summary>
        public Stopwatch ExecutionTimer { get; set; } = null;
    }
}
