namespace eProcurementNext.CommonModule.Exceptions
{
    public class SqlTableNotFoundException : Exception
    {
        public SqlTableNotFoundException()
        {

        }
        public SqlTableNotFoundException(string message)
           : base(message)
        {

        }

        public SqlTableNotFoundException(string message, Exception inner)
            : base(message, inner)
        {

        }
    }
}
