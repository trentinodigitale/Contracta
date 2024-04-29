namespace eProcurementNext.CommonModule.Exceptions
{
    public class SessionMongoDbException : Exception
    {
        public SessionMongoDbException()
        {

        }
        public SessionMongoDbException(string message)
           : base(message)
        {

        }

        public SessionMongoDbException(string message, Exception inner)
            : base(message, inner)
        {

        }
    }
}
