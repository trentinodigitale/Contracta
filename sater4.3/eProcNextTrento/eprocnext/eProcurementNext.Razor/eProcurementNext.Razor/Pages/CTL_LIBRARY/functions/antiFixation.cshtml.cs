using Microsoft.AspNetCore.Mvc.RazorPages;

namespace eProcurementNext.Razor.Pages.CTL_LIBRARY.functions
{
    public class antiFixationModel : PageModel
    {
        public static dynamic getTecDate(dynamic timeSep)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.functions.antiFixationModel.getTecDate(timeSep);
        }

        public void OnGet()
        {
        }
    }
}
