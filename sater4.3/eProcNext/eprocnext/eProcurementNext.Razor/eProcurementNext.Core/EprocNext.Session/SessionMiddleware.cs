using eProcurementNext.Application;
using eProcurementNext.Authentication;
using eProcurementNext.BizDB;
using eProcurementNext.CommonModule;
using eProcurementNext.Core.Pages.CTL_LIBRARY.functions;
using eProcurementNext.Razor;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;

namespace eProcurementNext.Session
{
    public class SessionMiddleware
    {
        private readonly RequestDelegate _next;
        private ITabManage _tabManage;
        //private EprocNext.Session.ISession _session;

        public static string Cookie_Auth_Name;

        public static string Cookie_Anon_Name;

        public static string DefaultHomePage;

        public static string Unauthorized;

        //private string _loginPath;

        const string LoginPathDefault = "/demo/index";
        const string defaultPath = "/";
        private static string _loginPath = string.Empty;

        public bool forceIsNotFreePage = false;


		public static string LoginPath
        {
            get { return _loginPath; }
            set
            {
                if (string.IsNullOrEmpty(_loginPath))
                {
                    _loginPath = value;
                }
            }
        }


        public SessionMiddleware(RequestDelegate next, ITabManage tabManage/*, EprocNext.Session.ISession session*/)
        {
            _next = next;
            //_tabManage = tabManage;
            //_session = session;
        }

        public async Task Invoke(HttpContext httpContext, eProcurementNext.Session.ISession _session)
        {
            //se l'url contiene doppi slash, reindirizzo la request all'url corretto.
            //Es //"//CTL_LIBRARY/functions/FIELD/DisplayAttach.asp" --> "/CTL_LIBRARY/functions/FIELD/DisplayAttach.asp"
            string originalPath = CommonModule.Basic.getPathRequest(httpContext.Request);
			string path = CommonModule.Basic.NormalizeUrlSlashes(originalPath);
            if (path != originalPath)
            {
                httpContext.Response.Redirect(path + httpContext.Request.QueryString);
                return;
            }
            bool isAspPage = path.ToLower().EndsWith(".asp", StringComparison.Ordinal) || path.ToLower().EndsWith(".aspx", StringComparison.Ordinal);

            //non effettuo alcun controllo se la path richiesta è vuota oppure se non mi trovo su una .asp o .aspx (non controlliamo la sessione per i file statici)
            if (string.IsNullOrEmpty(path) || !isAspPage)
            {
                await _next(httpContext);
                return;
            }

            string? tokenAnon = string.Empty, tokenAuth = string.Empty;
            bool hasAuthToken = httpContext.Request.Cookies.TryGetValue(Cookie_Auth_Name, out tokenAuth) && !string.IsNullOrEmpty(tokenAuth);
            bool hasAnonToken = httpContext.Request.Cookies.TryGetValue(Cookie_Anon_Name, out tokenAnon) && !string.IsNullOrEmpty(tokenAnon);
            bool isBackOffice = CheckSessionModel.IsIpBackOffice(httpContext);
            bool isFreePage = CheckSessionModel.IsFreePage(httpContext);
            bool isNoRefreshSessionPage = CheckSessionModel.IsNoRefreshSessionPage(httpContext);
            bool isProd;
            try
            {
                isProd =
                    !(ApplicationCommon.Application["debug-mode"].ToLower() == "yes" ||
                    ApplicationCommon.Application["debug-mode"].ToLower() == "si" ||
                    ApplicationCommon.Application["debug-mode"].ToLower() == "true");
            }
            catch
            {
                isProd = true;
            }

            // se la path è una pagina asp e questa non è presente nell'elenco delle pagine "NoRefresh" cerco di fare il refresh della session associata al token
            if (isAspPage && !isNoRefreshSessionPage)
            {
                //TODO salva se ho fatto la refresh per Sessione scaduta
                CheckSessionModel.TrySessionRefresh(_session, isAspPage, hasAuthToken, hasAnonToken, tokenAuth, tokenAnon, path);
            }

            string? mySecret = ConfigurationServices.GetKey("JWT:Secret");
            string? myIssuer = ConfigurationServices.GetKey("JWT:Issuer");
            string? myAudience = ConfigurationServices.GetKey("JWT:Audience");

			JWT jwt = new(mySecret, myIssuer, myAudience);

            //se non è un ip backoffice e la pagina ha il controllo di sessione
            if (!isBackOffice && (!isFreePage || forceIsNotFreePage))
            {
                string motivo = string.Empty;

                if (!hasAuthToken)
                {
                    motivo = "Utente non autorizzato: ripetere il login";

                }
                else if (!CheckSessionModel.CheckJWTToken(jwt, hasAuthToken, tokenAuth, isProd))
                {
                    motivo = "Validazione Token JWT non riuscita";

                }
                else if (!_session.IsActive(tokenAuth))
                {
                    motivo = "Sessione scaduta";
                }
                else
                {
                    _session.Load(tokenAuth);
                    if (_session["SessionIsAuth"] != true)
                    {
                        motivo = "Session hijacking: ripetere il login";
                    }
                    else
                    {
                        CheckSessionModel.CheckSession(_session, httpContext, ref motivo);
                    }

                }

                if (!string.IsNullOrEmpty(motivo))
                {
                    SessionMiddleware.DeleteAllCookies(httpContext);
                    httpContext.Response.Redirect(Unauthorized + @"?message=" + System.Web.HttpUtility.UrlEncode(motivo));
                    return;
                }

            }

            //Determina se fare o meno il log della risorsa, con o senza sessione
            if (isAspPage && IsLogRequired(path))
            {

                if (hasAuthToken == false && hasAnonToken == false)
                {
                    LogRequestPath(httpContext, _session);
                }
                else
                {
                    if (hasAuthToken && tokenAuth != null && _session.IsActive(tokenAuth))
                    {
                        _session.Load(tokenAuth);
                        LogRequestPath(httpContext, _session);
                    }
                    else if (hasAnonToken && tokenAnon != null && _session.IsActive(tokenAnon))
                    {
                        _session.Load(tokenAnon);
                        LogRequestPath(httpContext, _session);
                    }
                    else
                    {
                        LogRequestPath(httpContext, _session);
                    }
                }

            }

            await _next(httpContext);

        }

        public static void LoadSession(HttpContext ctx, ISession session, bool registrazione = false)
        {
            //Controlla esistenza Token JWT Autenticato
            string tokenAuth = null;
            if (ctx.Request.Cookies.TryGetValue(Cookie_Auth_Name, out tokenAuth) && session.IsActive(tokenAuth))
            {
                session.Load(tokenAuth);
                return;
            }

            //Controlla esistenza Token JWT Anonimo
            string tokenA = null;
            if (ctx.Request.Cookies.TryGetValue(Cookie_Anon_Name, out tokenA) && session.IsActive(tokenA))
            {
                session.Load(tokenA);
                return;
            }

            //Avvio sessione anonima con JWT_Toke Anonimo
            Authentication.IEprocNextAuthentication _JWTauth = new Authentication.JWT(SessionCommon.Configuration);
            string tokenGenerated = _JWTauth.GenerateToken();
            session.Init(tokenGenerated);

            bool Cookie_HttpOnly = CommonModule.Basic.CStr(ConfigurationServices.GetKey("Cookie_HttpOnly", "true")).ToLower() == "true";
            bool Cookie_Secure = CommonModule.Basic.CStr(ConfigurationServices.GetKey("Cookie_Secure", "true")).ToLower() == "true";

            if (registrazione)
            {
			    if (CommonModule.Basic.CStr(ConfigurationServices.GetKey("Cookie_Registrazione_Secure", "true")).ToLower() == "false")
			    {
				    Cookie_Secure = false;
			    }
            }

			ctx.Response.Cookies.Append(Cookie_Anon_Name, tokenGenerated, new CookieOptions() { HttpOnly = Cookie_HttpOnly, Secure = Cookie_Secure });

            MainGlobalAsa.Session_onStart(session);


        }
        
        public static void DeleteAnonymousCookie(HttpContext ctx)
        {
            ctx.Response.Cookies.Delete(Cookie_Anon_Name);
        }

        public static void DeleteAllCookies(HttpContext ctx, bool forceAll = false)
        {
            foreach (var cookie in ctx.Request.Cookies.Keys)
            {
                if (cookie == Cookie_Anon_Name || cookie == Cookie_Auth_Name || forceAll)
                    ctx.Response.Cookies.Delete(cookie);
            }
        }

        public static bool IsLogRequired(string path)
        {
            string requestPage = path.ToLower();
            IEnumerable<string?> pages = SessionCommon.Configuration.GetSection("CheckSessionExcludedPagesToLog").AsEnumerable().ToList().Select(kv => kv.Value);

            foreach (string? page in pages)
            {
                if (!string.IsNullOrEmpty(page))
                {
                    string tmpPage = CommonModule.Basic.ReplacePlaceholders(page).ToLower().Trim();
                    if (tmpPage.StartsWith("*", StringComparison.Ordinal))
                    {
                        tmpPage = tmpPage.Substring(1);
                    }
                    if (requestPage.EndsWith(tmpPage, StringComparison.Ordinal))
                    {
                        return false;
                    }
                }
            }

            return true;
        }

        private void LogRequestPath(HttpContext httpContext, eProcurementNext.Session.ISession session)
        {
            try
            {
                logModel.Log(httpContext, session);
            }
            catch (Exception ex)
            {
                CommonDB.Basic.TraceErr(ex, ApplicationCommon.Application.ConnectionString);
            }
        }
    }

    public static class SessionMiddlewareExtensions
    {
        public static IApplicationBuilder UseSessionMiddleware(
            this IApplicationBuilder builder)
        {
            return builder.UseMiddleware<SessionMiddleware>();
        }
    }
}
