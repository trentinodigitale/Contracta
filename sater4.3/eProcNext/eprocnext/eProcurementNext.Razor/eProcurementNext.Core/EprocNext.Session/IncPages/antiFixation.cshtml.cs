using Microsoft.AspNetCore.Mvc.RazorPages;

namespace eProcurementNext.Core.Pages.CTL_LIBRARY.functions
{
    public class antiFixationModel : PageModel
    {
        public static dynamic getTecDate(dynamic timeSep)
        {
            //strYearNow & "-" & strMonthNow & "-" & strDayNow & timeSep & strHourNow & ":" & strMinNow & ":" & strSecNow 
            var getTecDate = DateTime.Now.ToString($"yyyy-MM-dd{timeSep}HH:mm:ss");
            return getTecDate;
        }

        public void OnGet()
        {
        }
    }
}

