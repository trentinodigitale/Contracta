namespace eProcurementNext.Core.Storage.Interfaces
{
    public interface IeProcNextFileStorage
    {
        Task GetAsync(string fullName, Action<Stream> action);
        Task<Stream> GetAsync(string fullName);
    }
}
