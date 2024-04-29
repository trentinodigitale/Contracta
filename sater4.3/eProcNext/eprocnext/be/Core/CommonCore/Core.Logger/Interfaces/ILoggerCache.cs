using System;
using System.Collections.Generic;
using System.Text;

namespace Core.Logger.Interfaces
{
    public interface ILoggerCache
    {
        void SetValue<T>(string key, T value) where T : class;
        void SetValue(string key, string value);
        T GetValue<T>(string key) where T : class;
        string GetValue(string key);
    }
}
