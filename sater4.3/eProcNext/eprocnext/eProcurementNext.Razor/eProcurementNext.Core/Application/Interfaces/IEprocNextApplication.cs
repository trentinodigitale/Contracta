namespace eProcurementNext.Application
{
    public interface IEprocNextApplication
    {
        public dynamic? this[string propertyName] { get; set; }

        public bool KeyExists(string propertyName);

        public string ConnectionString { get { return this["ConnectionString"]; } }
    }
}
