using Core.Logger.HelkLogEntry;
using Core.Logger.Interfaces;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;

namespace Core.Logger.AbstractClasses
{
    public abstract class AbsSQLLoggerRepository<TIn, TOut> : ISqlLoggerRepository<TIn, TOut>
    {
        protected IDbConnection Connection { get; }
        protected ILoggerCache LoggerCache { get; }

        public AbsSQLLoggerRepository(IConfiguration config, ILoggerCache cache)
        {
            Connection = new SqlConnection(config.GetConnectionString("Repository"));
            LoggerCache = cache;
        }

        public abstract TIn GetInfo(TOut param);

        public virtual void SaveLogEntry<T>(StandardHelkLogEntry<T> logEntry)
        {
            // TODO
        }
    }
}
