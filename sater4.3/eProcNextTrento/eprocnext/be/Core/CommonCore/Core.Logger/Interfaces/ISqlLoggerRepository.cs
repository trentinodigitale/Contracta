using Core.Logger.HelkLogEntry;

namespace Core.Logger.Interfaces
{
    public interface ISqlLoggerRepository<TOut, TIn>
    {
        TOut GetInfo(TIn param);
        void SaveLogEntry<T>(StandardHelkLogEntry<T> logEntry);
    }
}
