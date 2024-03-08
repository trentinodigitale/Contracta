using eProcurementNext.CommonModule;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Primitives;


namespace eProcurementNext.Authentication
{
    public interface IAuthHandlerCustom
    {
        string? Token { get; set; }
        bool HasToken(HttpContext context);

        bool IsAuthorized(string token);
    }

    public class AuthHandlerCustom : IAuthHandlerCustom
    {
        private readonly IHttpContextAccessor _contextAccessor;
        private readonly IEprocNextAuthentication _jwt;
        private readonly IHostEnvironment _hostEnvironment;

        public AuthHandlerCustom(IHttpContextAccessor contextAccessor, IEprocNextAuthentication jwt, IHostEnvironment hostEnvironment)
        {
            _jwt = jwt;
            _contextAccessor = contextAccessor;
            _hostEnvironment = hostEnvironment;

            Token = null;
            if (_contextAccessor.HttpContext != null)
            {
                StringValues sv = _contextAccessor.HttpContext.Request.Headers.Authorization;
                foreach (var el in sv)
                {
                    if (el.StartsWith("Bearer ", StringComparison.Ordinal))
                    {
                        Token = Utility.ParseBearer(el);
                        break;
                    }
                }

                if (
                    ConfigurationServices.GetKey("Cookie_Auth_Name") != null &&
                    _contextAccessor.HttpContext.Request.Cookies.TryGetValue(ConfigurationServices.GetKey("Cookie_Auth_Name")!, out string? tokenAuth)
                    && tokenAuth != null
                    )
                {
                    Token = Utility.ParseBearer(tokenAuth);
                }
            }
            if (Token == null)
            {
                throw new AuthorizedException();
            }

            if (!_jwt.ValidateCurrentToken(Token, !hostEnvironment.IsDevelopment()))
            {
                throw new AuthorizedException();
            }


        }
        public string? Token { get; set; } = null;


        bool IAuthHandlerCustom.HasToken(HttpContext context)
        {
            if (Token != null)
            {
                return true;
            }
            return false;

        }

        bool IAuthHandlerCustom.IsAuthorized(string token)
        {
            return false;
        }
    }


    public static partial class ServiceCollectionExtensions
    {
        public static IServiceCollection AddAuthHandlerCustom(this IServiceCollection services)
        {
            services.AddTransient<IAuthHandlerCustom, AuthHandlerCustom>();
            return services;
        }
    }
}
