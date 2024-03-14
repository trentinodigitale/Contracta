namespace eProcurementNext.Cache
{
    public partial class EProcNextCache : IEprocNextCache
    {
        public DateTime LastUpdate
        {
            get { return (DateTime)this[EProcNextCacheProperty.LastUpdate]; }
            private set { this[EProcNextCacheProperty.LastUpdate] = value; }
        }
    }
}