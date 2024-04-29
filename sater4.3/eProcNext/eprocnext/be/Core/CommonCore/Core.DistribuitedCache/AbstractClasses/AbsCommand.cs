using Core.DistribuitedCache.Interfaces;
using Microsoft.Extensions.Caching.Distributed;
using System.Threading.Tasks;

namespace Core.DistribuitedCache.Manager.AbstractClasses
{
    public abstract class AbsCommand<TIn> : ICommand<IDistributedCache>, ICommandAsync<IDistributedCache>
    {
        protected TIn CommandData { get; }

        protected AbsCommand(TIn data)
        {
            CommandData = data;
        }

        protected abstract void ExecuteReceiverMethod(IDistributedCache receiver);

        protected abstract Task ExecuteReceiverMethodAsync(IDistributedCache receiver);

        public virtual void Execute(IDistributedCache receiver)
        {
            ExecuteReceiverMethod(receiver);
        }

        public async Task ExecuteAsync(IDistributedCache receiver)
        {
            await ExecuteReceiverMethodAsync(receiver);
        }
    }

    public abstract class AbsCommand<TIn, TOut> : AbsCommand<TIn>, ICommandResult<TOut>
    {
        public TOut Result { get; protected set; } = default;

        protected AbsCommand(TIn data) : base(data)
        { }
    }
}
