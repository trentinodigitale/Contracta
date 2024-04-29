using eProcurementNext.Application;
using Microsoft.AspNetCore.Mvc.RazorPages;
using static eProcurementNext.CommonModule.Basic;
using Basic = eProcurementNext.CommonDB.Basic;

namespace eProcurementNext.Razor.Pages.PCP
{
    public class PCP_testPCP : PageModel
    {
        public string? testPCP(int idDoc)
        {
            string res = string.Empty;

            try
            {
                string urlToInvoke = $@"/WebApiFramework/api/Tools/testPCP?idDoc={idDoc}";

                if (!Uri.IsWellFormedUriString(urlToInvoke, UriKind.Absolute))
                {
                    urlToInvoke = ApplicationCommon.Application["WEBSERVERAPPLICAZIONE_INTERNO"] + urlToInvoke;
                }

                res = invokeUrl(urlToInvoke);
            }
            catch (Exception ex)
            {
                //Se l'eccezione è nel formato standard restituito dalla invokeUrl, prendo solo il messaggio di errore
                if (ex.Message.IndexOf("Output: ") != -1)
                {
                    res = ex.Message[(ex.Message.IndexOf("Output: ") + "Output: ".Length)..];
                    if (!res.StartsWith("0#"))
                    {
                        res = $"0#{res}";
                    }
                }
                else
                {
                    res = $"0#{ex.Message}";
                }
            }
            finally
            {
                if (res.StartsWith("0#"))
                    Basic.LogEvent(Basic.TsEventLogEntryType.Error, res, ApplicationCommon.Application["ConnectionString"], "PCP_RettificaAvviso");
            }


            if (res.StartsWith("0#") || res.StartsWith("1#"))
            {
                return res;
            }
            else if (!res.StartsWith("1#"))
            {
                return $"1#{res}";
            }
            else
            {
                return res;
            }
        }
    }
}
