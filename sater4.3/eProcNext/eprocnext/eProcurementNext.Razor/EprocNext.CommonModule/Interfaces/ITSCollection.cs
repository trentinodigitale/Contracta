namespace eProcurementNext.CommonModule
{
    public interface ITSCollection
    {
        public void Save();

        public dynamic? this[string propertyName] { get; set; }
    }
}
