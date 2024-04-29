using Core.Logger.HelkLogEntry;
using System.Threading.Tasks;

namespace Core.Logger.Interfaces
{
    public interface IEventHubClient
    {
        Task Send<T>(StandardHelkLogEntry<T> entry, string ConnectionString, string EventHubName);
    }
}
