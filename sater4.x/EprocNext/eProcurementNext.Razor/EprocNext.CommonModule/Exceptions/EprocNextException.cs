namespace eProcurementNext.CommonModule
{
    public class EprocNextException : Exception
    {
        public EprocNextException(string text) : base(text)
        {

        }

        public EprocNextException(string text, Exception inner) : base(text, inner)
        {

        }
    }

}
