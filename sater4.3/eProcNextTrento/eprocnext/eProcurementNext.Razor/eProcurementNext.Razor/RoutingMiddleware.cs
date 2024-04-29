using eProcurementNext.CommonModule;
using eProcurementNext.Core.Pages.CTL_LIBRARY.functions;

namespace eProcurementNext.Razor
{
    public class RoutingMiddleware
    {
        private readonly RequestDelegate _next;

        public RoutingMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task Invoke(HttpContext httpContext)
        {
            if (!string.IsNullOrEmpty(httpContext.Request.Path))
            {

                string? redirectCfg = ConfigurationServices.GetKey("Redirect");//ApplicationCommon.Configuration.GetSection("Redirect").Value;
                redirectCfg = eProcurementNext.CommonModule.Basic.ReplacePlaceholders(redirectCfg);
                if (!string.IsNullOrWhiteSpace(redirectCfg))
                {
                    foreach (string cfgPart in redirectCfg.Split(';'))
                    {
                        if (string.IsNullOrEmpty(cfgPart))
                        {
                            continue;
                        }

                        string[] redirectInfo = cfgPart.Split(',');

                        string pageRequest = eProcurementNext.CommonModule.Basic.getPathRequest(httpContext.Request);
                        string pageFrom = redirectInfo[0].Trim();


                        if (pageRequest.Equals(pageFrom, StringComparison.OrdinalIgnoreCase))
                        {
                            string httpsTest = httpContext.Request.IsHttps ? "https://" : "http://";

                            //Se NON sono in una chiamata di backoffice ed è stata configurata la chiave HttpProtocol
                            //  per la redirect non lascio decidere il protocollo alla request ( IsHttps ) ma prendo il valore dal config
                            if ( !CheckSessionModel.IsIpBackOffice(httpContext) && ConfigurationServices.HasKey("HttpProtocol"))
                            {
                                httpsTest = ConfigurationServices.GetKey("HttpProtocol") +  "://";
                            }
                            string pageTO = redirectInfo[1].Trim();
                            string destination = httpsTest + httpContext.Request.Host + pageTO + httpContext.Request.QueryString;
                            httpContext.Response.Redirect(destination);

                            // Non invoco i successivi middleware
                            return;

                        }
                    }
                }
            }
            // Attenzione al percorso richiesto quando si arriva a questo punto

            await _next(httpContext);
        }
    }

    public static class RoutingMiddlewareExtensions
    {
        public static IApplicationBuilder UseRoutingMiddleware(
            this IApplicationBuilder builder)
        {
            return builder.UseMiddleware<RoutingMiddleware>();
        }
    }
}
