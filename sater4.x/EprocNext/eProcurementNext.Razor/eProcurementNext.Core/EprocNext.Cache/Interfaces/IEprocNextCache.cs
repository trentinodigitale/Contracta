using eProcurementNext.CommonModule;

namespace eProcurementNext.Cache
{
    public interface IEprocNextCache : ITSCollection
    {
        public bool Exists(string key);

        public bool Remove(string key);

        public void RemoveAll();

        public string? GetML(string key);

        public void SetML(string key, string value);


        public IEnumerable<string> Keys { get; }
        //public dynamic this[string propertyName] { get; set; }

    }
}
