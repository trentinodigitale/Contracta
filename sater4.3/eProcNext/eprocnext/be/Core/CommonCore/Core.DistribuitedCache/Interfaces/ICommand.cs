using System.Threading.Tasks;

namespace Core.DistribuitedCache.Interfaces
{
    public interface ICommand<TReceiver>
    {
        void Execute(TReceiver receiver);
    }

    public interface ICommandAsync<TReceiver>
    {
        Task ExecuteAsync(TReceiver receiver);
    }

    public interface ICommandResult<TOut>
    {
        TOut Result { get; }
    }
}
