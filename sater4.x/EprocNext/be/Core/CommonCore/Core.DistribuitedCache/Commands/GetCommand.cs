using Core.DistribuitedCache.Manager.AbstractClasses;
using Microsoft.Extensions.Caching.Distributed;
using System.Text.Json;
using System.Threading.Tasks;

namespace Core.DistribuitedCache.Manager.Commands
{
    public class GetCommand<TOut> : AbsCommand<string, TOut> where TOut : class
    {
        public GetCommand(string key) : base(key)
        {
            
        }

        protected override void ExecuteReceiverMethod(IDistributedCache receiver)
        {
            var stringResult = receiver.GetString(CommandData);
            if (stringResult != null)
            {
                Result = JsonSerializer.Deserialize<TOut>(stringResult, new JsonSerializerOptions()
                {
                    PropertyNameCaseInsensitive = true
                });
            }
        }

        protected async override Task ExecuteReceiverMethodAsync(IDistributedCache receiver)
        {
            var stringResult = await receiver.GetStringAsync(CommandData);
            if (stringResult != null)
            {
                Result = JsonSerializer.Deserialize<TOut>(stringResult, new JsonSerializerOptions()
                {
                    PropertyNameCaseInsensitive = true
                });
            }
        }
    }

    public class GetCommand : GetCommand<string>
    {
        public GetCommand(string key) : base(key)
        { }

        protected override void ExecuteReceiverMethod(IDistributedCache receiver)
        {
            Result = receiver.GetString(CommandData);
        }

        protected async override Task ExecuteReceiverMethodAsync(IDistributedCache receiver)
        {
            Result = await receiver.GetStringAsync(CommandData);
        }
    }
}
