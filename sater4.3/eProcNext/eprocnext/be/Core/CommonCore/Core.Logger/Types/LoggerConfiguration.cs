using Core.Logger.Interfaces;
using System.Collections.Generic;

namespace Core.Logger.Types
{
    public class EndPointSave
    {
        public LogOutput LogOutput { get; set; }
        public string EndPoint { get; set; }
        public string EndPointName { get; set; }
    }

    public class LoggerConfiguration : ILoggerConfiguration
    {
        public LogLevel MinimunOutput { get; set; }
        public Dictionary<string, EndPointSave> EndPointSaveDictionary { get; set; }
    }
}
