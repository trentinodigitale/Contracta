namespace eProcurementNext.CommonModule.Exceptions
{
    public class DataEncryptionException : Exception
    {
        public DataEncryptionException()
        {

        }
        public DataEncryptionException(string message)
           : base(message)
        {

        }

        public DataEncryptionException(string message, Exception inner)
            : base(message, inner)
        {

        }
    }
}
