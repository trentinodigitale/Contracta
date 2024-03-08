using eProcurementNext.CommonModule;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace eProcurementNext.Razor.Pages.CTL_LIBRARY.functions
{

    public class intestModel : PageModel
    {
        public void OnGet()
        {
        }

        //<!-- #Include File="../Functions/verificabrowser.inc" -->
        //<!-- #Include File="../Functions/CheckSession.inc" -->
        //<!-- #Include File="../Functions/Initialize_Component.inc" -->
        //<!-- #Include File="../Functions/trace_in_log_utente.inc" -->
        //<!-- #Include File="../Functions/cnv.inc" -->


        //Per la traduzione della Viewer.asp traduzione non necessaria perchè questo metodo viene chiamato nella versione non accessibile
        public static void StartPage(EprocResponse htmlToReturn)
        {
            eProcurementNext.Core.Pages.CTL_LIBRARY.functions.intestModel.StartPage(htmlToReturn);
        }

    }
}
