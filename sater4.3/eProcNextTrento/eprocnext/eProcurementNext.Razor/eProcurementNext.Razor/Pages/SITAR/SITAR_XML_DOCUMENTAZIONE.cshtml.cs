using Microsoft.AspNetCore.Mvc.RazorPages;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.Razor.Pages.SITAR
{
    public class SITAR_XML_DOCUMENTAZIONEModel : PageModel
    {
        public void OnGet()
        {
        }

        public static string addOptionalTag(string Value, string tag)
        {
            //on error resume next

            string result = string.Empty;
            if (!String.IsNullOrEmpty(CStr(Value)))
            {
                try
                {
                    string encodedValue = encodeXML(Value);
                    result = "<" + tag + ">" + encodedValue + "</" + tag + ">" + Environment.NewLine;
                    //response.Write vbcrlf
                }
                catch { }
            }
            return result;

            //err.clear
            //on error goto 0

        }

        public static string encodeXML(string str)
        {
            //on error resume next

            string result = "";
            if (!String.IsNullOrEmpty(CStr(str)))
            {
                result = System.Net.WebUtility.HtmlEncode(str);
                result = result.Replace("'", "&apos;");
            }
            return result;
            //on error goto 0

        }
    }
}
