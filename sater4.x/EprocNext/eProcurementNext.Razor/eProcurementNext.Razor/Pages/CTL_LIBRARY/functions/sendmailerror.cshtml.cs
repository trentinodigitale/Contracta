using eProcurementNext.Email;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace eProcurementNext.Razor.Pages.CTL_LIBRARY.functions
{
    public class sendmailerrorModel : PageModel
    {

        public static void sendMailErrorBackoffice(dynamic oggettoMail, dynamic contestoApplicativo, dynamic errorMsg, dynamic errorNumber, dynamic errorSource, dynamic strErrorCause, HttpContext httpContext, eProcurementNext.Session.ISession session)
        {
            SendMailError.SendMailErrorBackoffice(oggettoMail, contestoApplicativo, errorMsg, errorNumber, errorSource, strErrorCause, httpContext, session);
        }


        public void OnGet()
        {

        }
    }
}
