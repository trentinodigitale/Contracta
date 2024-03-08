using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using Microsoft.AspNetCore.Mvc.RazorPages;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.Razor.Pages.CTL_LIBRARY.functions
{
    public class net_utilsModel : PageModel
    {
        public void OnGet()
        {
        }

        public static string getIpClient(HttpRequest Request)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.functions.net_utilsModel.getIpClient(Request);
        }

        public static string MAP_SHARE_WITH_DRIVE(string PercorsoDiRete)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.functions.net_utilsModel.MAP_SHARE_WITH_DRIVE(PercorsoDiRete);
        }

        public static string getFederaValues(string guid)
        {
            string _out = string.Empty;
            Dictionary<string, object?> sqlParams = new()
            {
                { "@fedguid", $"federa_{guid}" }
            };

            CommonDbFunctions cdf = new();

            string strSql = "select top 1 parametri from CTL_LOG_PROC with(nolock) where DOC_NAME = @fedguid";
            TSRecordSet? rs = cdf.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString, sqlParams);
            if (rs != null && rs.RecordCount > 0)
            {
                rs.MoveFirst();
                _out = CStr(rs["parametri"]);

                Task.Run(() =>
                {
                    string strSQL = "delete from CTL_LOG_PROC where DOC_NAME = @fedguid";
                    try
                    {
                        cdf.Execute(strSQL, ApplicationCommon.Application.ConnectionString, parCollection: sqlParams);
                    }
                    catch
                    {
                        // Se va in eccezione riproviamo 1 volta dopo 1 secondo di attesa
                        Thread.Sleep(1000); // Attendi 1 secondo
                        cdf.Execute(strSQL, ApplicationCommon.Application.ConnectionString, parCollection: sqlParams);                       
                    }
                });


            }
            return _out;
        }

    }
}
