using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.Razor.Pages.Report
{
    public class prn_tabella_punteggi_tecniciModel : PageModel
    {

        public void OnGet()
        {
        }

        public static Double ConvDbl(string str)
        {
            string v = string.Empty;
            v = str;
            if (InStr(1, CStr(0.5), ",") > 0)
            {
                v = Replace(v, ".", ",");
            }
            return CDbl(v);
        }

        public static string F(string v)
        {
            if (!string.IsNullOrEmpty(v))
            {
                if (Strings.InStr(1, CStr(0.5), ".") > 0)
                {
                    v = v.Replace(",", ".");
                }
                else
                {
                    v = v.Replace(".", ",");
                }

                v = Strings.FormatNumber(CDbl(v), 2);
                if (Strings.InStr(1, CStr(0.5), ".") > 0)
                {
                    v = v.Replace(".", "A");
                    v = v.Replace(",", ".");
                    v = v.Replace("A", ",");
                }
            }
            return v;
        }

        public static string F(double v)
        {
            string v2 = string.Empty;
            if (!IsNull(v))
            {
                v2 = Strings.FormatNumber(v, 2);
                if (Strings.InStr(1, CStr(0.5), ".") > 0)
                {
                    v2 = Replace(v2, ".", "A");
                    v2 = Replace(v2, ",", ".");
                    v2 = Replace(v2, "A", ",");
                }
            }
            return v2;
        }
    }
}
