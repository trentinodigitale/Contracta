using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using Microsoft.AspNetCore.Mvc.RazorPages;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.Razor.Pages.CTL_LIBRARY.functions.FIELD
{
    public class displayAttachModel : PageModel
    {

        public void OnGet()
        {
        }

        public static void MsgError(string path, string ErrText, HttpResponse httpResponse)
        {
            throw new ResponseRedirectException(path + "CTL_LIBRARY/MessageBoxWin.asp?ML=yes&MSG=" + URLEncode(TruncateMessage(ErrText)) + "&CAPTION=Errore&ICO=2", httpResponse);
        }

        public static void InsertInTable(dynamic lIdPfu, dynamic att_hash, CommonDbFunctions cdf)
        {

            if (!string.IsNullOrEmpty(CStr(lIdPfu)))
            {
                TSRecordSet rs = cdf.GetRSReadFromQuery_("select atr_idrow from CTL_ATTACH_READ where atr_hash='" + CStr(att_hash) + "' and atr_idpfu=" + CStr(lIdPfu), ApplicationCommon.Application.ConnectionString);
                if (rs.RecordCount > 0)
                {
                    rs.MoveFirst();
                }
                else
                {
                    cdf.Execute("insert into CTL_ATTACH_READ (atr_hash,atr_idpfu) values ('" + CStr(att_hash) + "'," + CStr(lIdPfu) + ")", ApplicationCommon.Application.ConnectionString);
                    //DataRow dr = rs.AddNew();
                    //dr["atr_hash"] = cstr(att_hash);
                    //dr["atr_idpfu"] = cstr(lIdPfu);
                    //rs2.Update(dr, "ATR_IdRow", "CTL_ATTACH_READ"); // TODO verificare Update (colonna identit�)


                    // getRs("insert into CTL_ATTACH_READ (atr_hash,atr_idpfu) values ('" & cstr(att_hash) & "'," & cstr(lIdPfu) & ")" )
                }

                //rs = null;
            }

        }

        public static void RedirectOrShowMessage(string url, IEprocResponse objResp, string message, HttpResponse httpResponse)
        {
            if (IsUrlValid(url))
            {
                throw new ResponseRedirectException(url, httpResponse);
            }
            else
            {
                objResp.Clear();
                objResp.Write("Allegato al momento non disponibile. Riprovare pi� tardi");
                throw new ResponseEndException(objResp.Out(), httpResponse, "");
            }
        }

    }
}
