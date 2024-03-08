using eProcurementNext.Application;
using Microsoft.AspNetCore.Mvc.RazorPages;
using static eProcurementNext.CommonModule.Basic;
namespace eProcurementNext.Razor.Pages.CTL_LIBRARY
{
    public class cookie_bannerModel : PageModel
    {

        public void OnGet()
        {
        }
        public static string COOKIE_BANNER(string str, HttpContext httpContext)
        {
            //'--verifica la presenza del cookie e se non scaduto
            HttpRequest Request = httpContext.Request;
            string cookie_value;
            string strOut = "";

            cookie_value = Request.Cookies["COOKIE_BANNER"];

            //'--Se esiste significa che non è scaduto
            if (!string.IsNullOrEmpty(cookie_value))
            {
                strOut = "";
            }
            else
            {
                //'--Mostra il banner e sul chiudi settiamo il cookie con scadenza 1 mese
                string virtualDirectoryPortale = ApplicationCommon.Application["NOMEAPPPORTALE_JOOMLA"]; 

					//virtualDirectoryPortale = CStr(CStr(httpContext.Request.Path.ToString().Split("/")[1]));

				string strVirtualDirectory = ApplicationCommon.Application["strVirtualDirectory"];

                string versioneAflink = "";
                versioneAflink = URLEncode(CStr(ApplicationCommon.Application["VERSIONE_AFLINK"]));
                if (string.IsNullOrEmpty(versioneAflink))
                {
                    versioneAflink = "0";
                }
                string COOKIE_BANNER_MSG = ApplicationCommon.CNV("COOKIE_BANNER_MSG");

                strOut = $@"<link rel=""stylesheet"" href=""" + strVirtualDirectory + $@"/CTL_Library/Themes/cookie_banner.css?v=" + versioneAflink + $@"""  type=""text/css"" media=""screen,projection""/>";
                strOut = strOut + $@"<div class=""cookie-consent"" style=""position: fixed;width:100%;bottom:40px;"" id=""cookie-consent"">";
                strOut = strOut + $@"<div class=""cookie-container"">";
                strOut = strOut + COOKIE_BANNER_MSG;
                strOut = strOut + $@"	<button class=""btn-cookie-consent"" id=""consent"">Chiudi</button>";
                strOut = strOut + "</div>";
                strOut = strOut + "</div>";
                strOut = strOut + $@"<script src=""/" + virtualDirectoryPortale + $@"/JS/JUI/js/jquery.min.js?v=" + versioneAflink + $@""" type=""text/javascript""></script>";
                strOut = strOut + $@"<script type=""text/javascript"" >";
                strOut = strOut + $@"	$(function ()  ";
                strOut = strOut + $@" {{";
                strOut = strOut + $@"$('#consent').on('click', function () {{";
                strOut = strOut + $@"document.cookie = ""COOKIE_BANNER=cookieValue; max-age=2592000; path=/;"";";
                strOut = strOut + $@"$('cookie-consent').hide();";
                strOut = strOut + $@"}});";
                strOut = strOut + $@"}});";
                strOut = strOut + "</script>";
            }
            return strOut;
        }


    }
}
