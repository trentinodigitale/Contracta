using Microsoft.AspNetCore.Mvc.RazorPages;

namespace eProcurementNext.Razor.Pages.CTL_LIBRARY.functions
{
    public class logModel : PageModel
    {
        public void OnGet()
        {
        }

        public static void Log(HttpContext httpContext, eProcurementNext.Session.ISession session)
        {
            eProcurementNext.Core.Pages.CTL_LIBRARY.functions.logModel.Log(httpContext, session);
        }
    }
}
