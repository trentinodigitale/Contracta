namespace eProcurementNext.CommonModule.Exceptions
{
    public class SqlUpdateException : Exception
    {
        public SqlUpdateException()
        {

        }
        public SqlUpdateException(string message)
           : base(message)
        {

        }

        public SqlUpdateException(string message, Exception inner)
            : base(message, inner)
        {

        }
    }
}
