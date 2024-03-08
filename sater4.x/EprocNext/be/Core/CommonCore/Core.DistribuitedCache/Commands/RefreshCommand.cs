using Core.DistribuitedCache.Manager.AbstractClasses;
using Microsoft.Extensions.Caching.Distributed;
using System.Threading.Tasks;

namespace Core.DistribuitedCache.Manager.Commands
{
    public class RefreshCommand : AbsCommand<string>
    {
        public RefreshCommand(string key) : base(key)
        { }

        protected override void ExecuteReceiverMethod(IDistributedCache receiver)
        {
            receiver.Refresh(CommandData);
        }

        protected async override Task ExecuteReceiverMethodAsync(IDistributedCache receiver)
        {
            await receiver.RefreshAsync(CommandData);
        }
    }
}
