using Core.Logger.HelkLogEntry.Types;
using Core.Logger.Types;
using System;
using System.Diagnostics;

namespace Core.Logger.Interfaces
{
    public interface ILogStatsData<T> where T: class
    {
        T Message { get; }
        ApplicationArea ApplicationArea { get; }
        ISpecificApplicationArea SpecificApplicationArea { get; }
    }

    public interface ILogEntryData<T> : ILogStatsData<T> where T : class
    {
        LogLevel Level { get; }
        int Retention { get; }
        string InputData { get; }
        int? ResponseStatusCode { get; set; }
        Stopwatch ExecutionTimer { get; }
        Exception LogException { get; }
    }
}
