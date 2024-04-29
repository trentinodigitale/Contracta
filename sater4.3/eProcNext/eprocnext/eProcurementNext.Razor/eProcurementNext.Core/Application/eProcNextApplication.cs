namespace eProcurementNext.Application
{
    public class eProcNextApplication : IEprocNextApplication
    {
        private Dictionary<string, object> _properties = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);

        public dynamic? this[string propertyName]
        {
            get
            {
                if (this._properties.ContainsKey(propertyName))
                {
                    // se ho la variabile localmente la restituisco
                    return this._properties[propertyName];
                }
                else
                {
                    return null;
                }
            }

            set
            {
                lock (_properties)
                {
                    this._properties[propertyName] = value;
                }
            }
        }

        public string ConnectionString { get { return this["ConnectionString"]; } }

        public bool KeyExists(string propertyName)
        {
            return this._properties.ContainsKey(propertyName);
        }
    }
}
