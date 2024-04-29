namespace eProcurementNext.CommonModule.Exceptions
{
    public class DataBlockCryptographicException : Exception
    {
        public DataBlockCryptographicException()
        {

        }
        public DataBlockCryptographicException(string message)
            : base(message)
        {

        }

        public DataBlockCryptographicException(string message, Exception inner)
            : base(message, inner)
        {

        }
    }
}