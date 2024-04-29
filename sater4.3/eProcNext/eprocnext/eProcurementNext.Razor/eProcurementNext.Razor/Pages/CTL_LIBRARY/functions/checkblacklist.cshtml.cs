using eProcurementNext.Application;
using Microsoft.AspNetCore.Mvc.RazorPages;
using static eProcurementNext.CommonModule.Const;

namespace eProcurementNext.Razor.Pages.CTL_LIBRARY.functions
{
    public class CheckBlackList : PageModel
    {
        HttpContext _httpContext;
        // CheckBlackList
        public CheckBlackList(HttpContext httpContext)
        {
            this._httpContext = httpContext;
        }

        public bool OnGet()
        {
            dynamic ip = net_utilsModel.getIpClient(_httpContext.Request);
            IEprocNextApplication _application = ApplicationCommon.Application;

            //' Se l'ip � presente nella blacklist
            Dictionary<string, dynamic> blackList = _application[APPLICATION_BLACKLIST];
            if (!String.IsNullOrEmpty(blackList.ContainsKey(ip)))
            {
                //'Se � presente NOMEAPPLICAZIONE nell'application
                if (!String.IsNullOrEmpty(_application["NOMEAPPLICAZIONE"]))
                {
                    _httpContext.Response.Redirect("/" + _application["NOMEAPPLICAZIONE"] + "/blocked.asp");
                }
                else
                {
                    _httpContext.Response.Redirect($@"{ApplicationCommon.Application["strVirtualDirectory"]}/blocked.asp");
                }
                return false;   // response.end
            }

            return true;
        }
    }
}
