using Core.Logger.Types;
using System.Collections.Generic;

namespace Core.Logger.Interfaces
{
    public interface ILoggerConfiguration
    {
        // LogOutput LogOutput { get; }
        LogLevel MinimunOutput { get; }
        Dictionary<string, EndPointSave> EndPointSaveDictionary { get; }
    }
}
