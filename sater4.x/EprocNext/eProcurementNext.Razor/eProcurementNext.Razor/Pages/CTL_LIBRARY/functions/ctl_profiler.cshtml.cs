using eProcurementNext.Application;
using eProcurementNext.BizDB;
using Microsoft.AspNetCore.Mvc.RazorPages;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.Razor.Pages.CTL_LIBRARY.functions
{
    public class ctl_profiler : PageModel
    {
        public void OnGet()
        {
        }

        public static void Write_CTL_Profiler(string PAGE, string OBJ, string ID, HttpRequest Request, dynamic TimeStartPage, IConfiguration configuration, eProcurementNext.Application.IEprocNextApplication _application)
        {
            //'-- TRACCIAMO IL TEMPO DI ESECUZIONE DELLA PAGINA
            dynamic TimeEndPage;
            TimeEndPage = DateTime.Now.Ticks;
            long lgTempoDiEsecuzione = CLng(TimeEndPage - TimeStartPage);

            long tempoDiEsecuzione = eProcurementNext.CommonModule.Basic.CLng(ConvertTicksToMilliSeconds(lgTempoDiEsecuzione));

            string VID_DOC = String.Empty;

            TabManage objDB = new TabManage(configuration);

            if (string.IsNullOrEmpty(ID))
            {
                VID_DOC = GetParamURL(Request.QueryString, "IDDOC");
                if (string.IsNullOrEmpty(VID_DOC) || Left(VID_DOC, 3).ToUpper() == "NEW")
                {
                    VID_DOC = "-1";
                }
            }
            else
            {
                VID_DOC = ID;
            }


            if (string.IsNullOrEmpty(OBJ))
            {
                OBJ = GetParamURL(Request.QueryString, "DOCUMENT").Replace("'", "''");
            }

            var sqlParams = new Dictionary<string, object?>();
            sqlParams.Add("@PAGE", PAGE);
            sqlParams.Add("@tempoDiEsecuzione", tempoDiEsecuzione);
            sqlParams.Add("@reqQS", GetQueryStringFromContext(Request.QueryString));
            sqlParams.Add("@OBJ", OBJ);
            sqlParams.Add("@VID_DOC", VID_DOC);
            string strSql = "insert into CTL_Profiler (Pagina, Timer, Url, TIPODOC ,IDDOC) values (@PAGE, @tempoDiEsecuzione, @reqQS, @OBJ, @VID_DOC)";

            objDB.ExecSql(strSql, ApplicationCommon.Application.ConnectionString, parCollection: sqlParams);
        }
    }
}
