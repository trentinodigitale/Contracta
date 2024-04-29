using eProcurementNext.Application;
using Microsoft.AspNetCore.Mvc.RazorPages;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.Razor.Pages.CTL_LIBRARY.PDF
{
    public class importa_zip_pdfModel : PageModel
    {
        public void OnGet()
        {
        }

        public static string newfirmaEstesaCOM(string mode, string strPathFile, string strHashName, string idAzi, string issigned, HttpContext httpContext, String accessGuid)
        {
            string stringToReturn = "";

            string AF_WebFileManager = "AF_WebFileManager";
            string urlToInvoke;
            if (!string.IsNullOrEmpty(ApplicationCommon.Application["NOMEAPPLICAZIONE_ALLEGATI"]))
            {
                AF_WebFileManager = ApplicationCommon.Application["NOMEAPPLICAZIONE_ALLEGATI"];
            }
            if (IsEmpty(ApplicationCommon.Application["WEBSERVERAPPLICAZIONE_INTERNO"]) || string.IsNullOrEmpty(ApplicationCommon.Application["WEBSERVERAPPLICAZIONE_INTERNO"]))
            {


                urlToInvoke = httpContext.GetServerVariable("LOCAL_ADDR") + "/" + AF_WebFileManager + "/proxy/1.0/pdfoperation?mode=";

            }
            else
            {

                urlToInvoke = ApplicationCommon.Application["WEBSERVERAPPLICAZIONE_INTERNO"] + "/" + AF_WebFileManager + "/proxy/1.0/pdfoperation?mode=";

            }


            urlToInvoke = urlToInvoke + URLEncode(mode) + "&pdf=" + URLEncode(strPathFile) + "&attHash=" + URLEncode(strHashName) + "&idAzi=" + URLEncode(idAzi) + "&issigned=" + URLEncode(issigned);

            urlToInvoke = urlToInvoke + "&acckey=" + URLEncode(CStr(accessGuid));

            //case "VERIFICA_PDF":
            //es: https://afsvm046.afsoluzioni.it/AF_WebFileManager/proxy/1.0/pdfoperation?mode=VERIFICA_PDF&pdf=d:\PortaleGareTelematiche\Allegati\Busta_TEC_77.pdf&attHash=FILE_ATT_HASH_GUID&idAzi=35152001&issigned=true
            //case "VERIFICA_P7M":
            //es: https://afsvm046.afsoluzioni.it/AF_WebFileManager/proxy/1.0/pdfoperation?mode=VERIFICA_P7M&pdf=d:\PortaleGareTelematiche\Allegati\Busta_TEC_77.pdf&attHash=FILE_ATT_HASH_GUID&idAzi=35152001

            stringToReturn = invokeUrl(urlToInvoke);

            return stringToReturn;
        }
    }
}
