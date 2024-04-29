using eProcurementNext.CommonModule;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace eProcurementNext.Razor.Pages.CTL_LIBRARY
{
    public class loadingModel : PageModel
    {

        public void OnGet()
        {
        }
        public static void loading(EprocResponse htmlToReturn)
        {
            htmlToReturn.Write($@"<center><div id=""MsgFirma"" style=><font class=""loading""></font></div></center>");
        }


    }
}
