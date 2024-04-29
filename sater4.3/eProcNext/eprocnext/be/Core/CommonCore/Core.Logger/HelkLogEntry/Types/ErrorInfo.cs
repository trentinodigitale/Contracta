namespace Core.Logger.HelkLogEntry.Types
{
    public class ErrorInfo
    {
        /// <summary>
        /// Name of the type of exception generated.
        /// I.e. => java.lang.NullPointerException
        /// </summary>
        public string Type { get; set; }
        public string Message { get; set; }
        public string Stack_trace { get; set; }
    }
}
