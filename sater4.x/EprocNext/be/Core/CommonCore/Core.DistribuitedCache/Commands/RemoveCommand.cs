using Core.DistribuitedCache.Manager.AbstractClasses;
using Microsoft.Extensions.Caching.Distributed;
using System.Threading.Tasks;

namespace Core.DistribuitedCache.Manager.Commands
{
    public class RemoveCommand : AbsCommand<string>
    {
        public RemoveCommand(string key) : base(key)
        { }

        protected override void ExecuteReceiverMethod(IDistributedCache receiver)
        {
            receiver.Remove(CommandData);
        }

        protected async override Task ExecuteReceiverMethodAsync(IDistributedCache receiver)
        {
            await receiver.RemoveAsync(CommandData);
        }
    }
}
