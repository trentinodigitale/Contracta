namespace eProcurementNext.CommonModule
{
    public class CustomException : Exception
    {
        public string message;
        string number;
        public string stackTrace;
        public int statusCode;

        public CustomException() : base() { }
        public CustomException(string _message) : base(_message)
        {
            message = _message;
        }
        public CustomException(string _message, Exception innerException) : base(_message, innerException)
        {
            message = _message;
            stackTrace = innerException.StackTrace ?? "";
        }
        public CustomException(Exception innerException) : base("", innerException)
        {
            stackTrace = innerException.StackTrace ?? "";
        }
    }

    public class AuthorizedException : CustomException
    {
        public AuthorizedException() : base()
        {
            base.statusCode = 401;
            base.message = "Not Authorized";
        }
    }
}
