using eProcurementNext.Authentication;
using eProcurementNext.Core.Pages.CTL_LIBRARY.functions;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;


namespace eProcurementNext.Core.Handler
{
    public interface ILogHandler
    {
        void AddLog(string message);
    }

    public class LogHandler : ILogHandler
    {
        private readonly IHttpContextAccessor _contextAccessor;

        private readonly IAuthHandlerCustom _authHandlerCustom;

        private readonly Session.ISession? _session;

        public LogHandler(IHttpContextAccessor contextAccessor, IAuthHandlerCustom authHandlerCustom, eProcurementNext.Session.ISession session)
        {
            _contextAccessor = contextAccessor;
            _authHandlerCustom = authHandlerCustom;
            _session = session;
            try
            {
                _session.Load(_authHandlerCustom.Token);
            }
            catch
            {
                _session = null;
            }

            logModel.Log(_contextAccessor.HttpContext, _session);
        }

        public void AddLog(string message)
        {
            logModel.Log(_contextAccessor.HttpContext, _session);
        }
    }

    public static partial class ServiceCollectionExtensions
    {
        public static IServiceCollection AddLogHandler(this IServiceCollection services)
        {
            services.AddTransient<ILogHandler, LogHandler>();
            return services;
        }
    }
}
