using log4net;
using log4net.Appender;
using log4net.Core;
using log4net.Layout;
using log4net.Repository.Hierarchy;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;

namespace FTM.Cloud.Common.Helpers
{
    public class LogHelper
    {
        public const string DEFAULT_LOG_CONTEXT = "FTM";
        private const string LOGGER_NAME = "FTM.Cloud.Common.Helpers";

        private static readonly ILog log = LogManager.GetLogger(typeof(LogHelper));
        private static Dictionary<string, ILog> logIstances = new Dictionary<string, ILog>();

        public static void Setup(List<string> contextList = null)
        {
            var hierarchy = (Hierarchy)LogManager.GetRepository(Assembly.GetEntryAssembly());
            hierarchy.Threshold = Level.All;

            var defaultlogger = hierarchy.LoggerFactory.CreateLogger(hierarchy, DEFAULT_LOG_CONTEXT);
            defaultlogger.Hierarchy = hierarchy;
            defaultlogger.AddAppender(CreateFileAppender(DEFAULT_LOG_CONTEXT));
            defaultlogger.Repository.Configured = true;
            defaultlogger.Level = Level.Debug;

            ILog defaultLog = new LogImpl(defaultlogger);
            logIstances.Add(DEFAULT_LOG_CONTEXT, defaultLog);
        }

        private static void addContext(string logContext)
        {
            var hierarchy = (Hierarchy)LogManager.GetRepository(Assembly.GetEntryAssembly());
            hierarchy.Threshold = Level.All;

            var customLogger = hierarchy.LoggerFactory.CreateLogger(hierarchy, logContext);
            customLogger.Hierarchy = hierarchy;
            customLogger.AddAppender(CreateFileAppender(logContext));
            customLogger.Repository.Configured = true;

            var logLevel = ConfigurationHelper.LogLevel;
            switch (logLevel.ToLower())
            {
                case "info":
                    customLogger.Level = Level.Info;
                    break;

                case "warn":
                case "warning":
                    customLogger.Level = Level.Warn;
                    break;

                case "err":
                case "error":
                    customLogger.Level = Level.Error;
                    break;

                case "debug":
                    customLogger.Level = Level.Debug;
                    break;

                default:
                    customLogger.Level = Level.All;
                    break;
            }

            ILog customLog = new LogImpl(customLogger);
            logIstances.Add(logContext, customLog);
        }

        private static IAppender CreateFileAppender(string contextName)
        {
            PatternLayout patternLayout = new PatternLayout();
            patternLayout.ConversionPattern = "%date{HH:mm:sszz} %level %logger: %message%newline";
            patternLayout.ActivateOptions();

            RollingFileAppender appender = new RollingFileAppender();
            appender.Name = contextName;
            appender.File = string.Format(@"logs/{0}_{1}.log", DateTime.Today.ToString("yyyyMMdd"), contextName);
            appender.AppendToFile = true;
            appender.MaxSizeRollBackups = 10;
            appender.RollingStyle = RollingFileAppender.RollingMode.Composite;
            appender.MaximumFileSize = "10MB";
            appender.CountDirection = 1;
            appender.Layout = patternLayout;
            appender.LockingModel = new FileAppender.MinimalLock();
            appender.StaticLogFileName = true;
            appender.ActivateOptions();

            return appender;
        }

        // Set the level for a named logger
        public static void SetLevel(string loggerName, string levelName)
        {
            log4net.ILog log = log4net.LogManager.GetLogger(Assembly.GetEntryAssembly(), loggerName);
            log4net.Repository.Hierarchy.Logger l =
          (log4net.Repository.Hierarchy.Logger)log.Logger;

            l.Level = l.Hierarchy.LevelMap[levelName];
        }

        public static void Info(string message, string logContext = DEFAULT_LOG_CONTEXT)
        {
            if (!logIstances.Keys.Contains(logContext))
                addContext(logContext);

            ILog log = logIstances[logContext];


            log.Info(string.Format(message));
        }

        public static void Debug(string message, string logContext = DEFAULT_LOG_CONTEXT)
        {
            if (!logIstances.Keys.Contains(logContext))
                addContext(logContext);

            ILog log = logIstances[logContext];

            log.Debug(string.Format(message));
        }

        public static void Warn(string message, string logContext = DEFAULT_LOG_CONTEXT)
        {
            if (!logIstances.Keys.Contains(logContext))
                addContext(logContext);

            ILog log = logIstances[logContext];

            log.Warn(string.Format(message));
        }

        public static void Error(string message, string logContext = DEFAULT_LOG_CONTEXT)
        {
            if (!logIstances.Keys.Contains(logContext))
                addContext(logContext);

            ILog log = logIstances[logContext];

            log.Error(string.Format(message));
        }

        public static void Fatal(string message, string logContext = DEFAULT_LOG_CONTEXT)
        {
            if (!logIstances.Keys.Contains(logContext))
                addContext(logContext);

            ILog log = logIstances[logContext];

            log.Fatal(string.Format(message));
        }
        
    }

}
