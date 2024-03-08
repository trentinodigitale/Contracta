using eProcurementNext.CommonModule;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
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

        public AuthHandlerCustom(IHttpContextAccessor contextAccessor, IEprocNextAuthentication jwt)
        {
            _jwt = jwt;
            _contextAccessor = contextAccessor;

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
            }
            if (Token == null)
            {
                throw new AuthorizedException();
            }
            //TODO vedere appSetting progetto API e progetto Razor key jwt
            //if (!_jwt.ValidateCurrentToken(Token))
            //{
            //	throw new AuthorizedException();
            //}


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
