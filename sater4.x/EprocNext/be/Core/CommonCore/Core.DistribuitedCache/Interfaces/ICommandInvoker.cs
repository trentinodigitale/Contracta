using System.Threading.Tasks;

namespace Core.DistribuitedCache.Interfaces
{
    public interface ICommandInvoker<TReceiver>
    {
        void Execute<TCommand>(TCommand command) where TCommand : ICommand<TReceiver>;
    }

    public interface ICommandInvokerAsync<TReceiver>
    {
        Task ExecuteAsync<TCommand>(TCommand command) where TCommand : ICommandAsync<TReceiver>;
    }
}
