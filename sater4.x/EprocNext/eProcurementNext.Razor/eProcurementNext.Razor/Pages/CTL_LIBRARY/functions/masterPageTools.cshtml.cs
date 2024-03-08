
using Microsoft.AspNetCore.Html;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace eProcurementNext.Razor.Pages.CTL_LIBRARY.functions
{
    public class masterPageToolsModel : PageModel
    {

        public static void InitConfig(IConfiguration conf)
        {
            //_configuration = conf;

        }


        public void OnGet()
        {

        }

        //public static string GetParam(string? str, string? param)
        //{
        //    if(str == null || param == null)
        //    {
        //        return "";
        //    }

        //    dynamic ind, a, sa, pa;
        //    sa = Strings.UCase(str);
        //    pa = Strings.UCase(param);
        //    ind = Strings.InStr(1, sa, $"{pa}=");

        //    if (ind > 0)
        //    {
        //        a = Strings.Mid(str, ind + Strings.Len(param) + 1);
        //        ind = Strings.InStr(1, a, "&");
        //        if (ind > 0)
        //        {
        //            a = Strings.Left(a, ind - 1);
        //        }
        //        return a;
        //    }
        //    else
        //    {
        //        return "";
        //    }

        //}




        public static dynamic getStackKey(dynamic key, dynamic url)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.functions.masterPageToolsModel.getStackKey(key, url);
        }

        public static HtmlString drawContent()
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.functions.masterPageToolsModel.drawContent();
        }


        public static HtmlString drawLogo(String path)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.functions.masterPageToolsModel.drawLogo(path);
        }

        public static string addZero(dynamic str)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.functions.masterPageToolsModel.addZero(str);
        }


        public static void stackUpdateCurrentPosition(string key, string url, string title, eProcurementNext.Session.ISession _session, HttpContext _context)
        {
            eProcurementNext.Core.Pages.CTL_LIBRARY.functions.masterPageToolsModel.stackUpdateCurrentPosition(key, url, title, _session, _context);

        }

        public static void popBreadCrumb(string pathRoot, eProcurementNext.Session.ISession _session, HttpResponse response)
        {

            eProcurementNext.Core.Pages.CTL_LIBRARY.functions.masterPageToolsModel.popBreadCrumb(pathRoot, _session, response);


        }

        public static void toBreadCrumb(string pathRoot, int livelli, eProcurementNext.Session.ISession _session, HttpResponse response)
        {

            eProcurementNext.Core.Pages.CTL_LIBRARY.functions.masterPageToolsModel.toBreadCrumb(pathRoot, livelli, _session, response);


        }

        public static HtmlString drawTitle(eProcurementNext.Session.ISession session)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.functions.masterPageToolsModel.drawTitle(session);
        }

    }
}
