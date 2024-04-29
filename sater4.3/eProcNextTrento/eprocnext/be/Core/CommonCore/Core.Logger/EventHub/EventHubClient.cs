using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Producer;
using Core.Logger.HelkLogEntry;
using Core.Logger.Interfaces;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace Core.Logger.EventHub
{
    public class EventHubClient : IEventHubClient
    {
        public async Task Send<T>(StandardHelkLogEntry<T> entry, string ConnectionString, string EventHubName)
        {
            await using var producerClient = new EventHubProducerClient(ConnectionString, EventHubName);
            using EventDataBatch eventBatch = await producerClient.CreateBatchAsync();
            eventBatch.TryAdd(new EventData(Encoding.UTF8.GetBytes(JsonSerializer.Serialize(entry))));
            await producerClient.SendAsync(eventBatch);
        }
    }
}
