using System;

namespace Core.DTO.NoSql
{
    /// <summary>
    /// Exception class for long time processing
    /// </summary>
    public class LogException
    {
        /// <summary>
        /// Deserialization
        /// </summary>
        public LogException()
        {

        }

        /// <summary>
        /// ctor
        /// </summary>
        /// <param name="e"></param>
        public LogException(Exception e)
        {
            Source = e.Source;
            Message = e.Message;
            StackTrace = e.StackTrace;
        }

        /// <summary>
        /// message
        /// </summary>
        public string Message { get; set; }

        /// <summary>
        /// Exception stack trace
        /// </summary>
        public string StackTrace { get; set; }

        /// <summary>
        /// Source
        /// </summary>
        public string Source { get; set; }
    }

    /// <summary>
    /// Added Input property with input type parameter
    /// </summary>
    /// <typeparam name="TInput"></typeparam>
    public class LogException<TInput> : LogException
    {
        /// <summary>
        /// ctor
        /// </summary>
        /// <param name="ex"></param>
        public LogException(Exception ex) : base(ex)
        { }

        /// <summary>
        /// ctor
        /// </summary>
        /// <param name="ex"></param>
        /// <param name="inputData"></param>
        public LogException(Exception ex, TInput inputData) : base(ex)
        {
            InputData = inputData;
        }

        /// <summary>
        /// Input data that generated the exception
        /// </summary>
        public TInput InputData { get; set; }

        /// <summary>
        /// Tenant ID 
        /// </summary>
        public long TenantId { get; set; }
    }
}
