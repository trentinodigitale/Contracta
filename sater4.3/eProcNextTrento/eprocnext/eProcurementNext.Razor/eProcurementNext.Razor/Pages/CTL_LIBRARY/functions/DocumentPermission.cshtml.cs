using eProcurementNext.CommonModule;
using Microsoft.AspNetCore.Mvc.RazorPages;
//<!-- #INCLUDE FILE="net_utils.inc" -->


namespace eProcurementNext.Razor.Pages.CTL_LIBRARY.functions
{
    public class DocumentPermissionModel : PageModel
    {
        private IHttpContextAccessor Accessor;
        private HttpContext? _context;

        public DocumentPermissionModel(IHttpContextAccessor _accessor)
        {
            this.Accessor = _accessor;
            _context = this.Accessor.HttpContext;
        }

        public void OnGet()
        {

        }

        //'--per i documenti generici

        // Metodo commentato da Claudio in quanto ha 0 riferimenti
        //public static void DocGenPermission(int IDDOC, EprocNext.Session.ISession session, EprocResponse htmlToReturn, HttpRequest Request, HttpResponse Response)
        //{

        //    string strSQL = "";
        //    TSRecordSet? rs = null;
        //    string dcmDocPermission = "";
        //    if (IDDOC != -1)
        //    {
        //        strSQL = "select isnull(dcmDocPermission,'') as dcmDocPermission from DOCUMENT, TAB_MESSAGGI where idmsg=" + CLng(IDDOC) + " and dcmitype=msgitype and dcmisubtype=msgisubtype";
        //        CommonDbFunctions cdb = new CommonDbFunctions();
        //        rs = cdb.GetRSReadFromQuery_(CStr(strSQL), CStr(ApplicationCommon.Application["ConnectionString"]));
        //        if (rs.RecordCount > 0)
        //        {
        //            dcmDocPermission = GetValueFromRS(rs.Fields["dcmDocPermission"]);
        //            if (dcmDocPermission != "")
        //            {
        //                CheckDocPermission(dcmDocPermission, IDDOC, session["IdPfu"], "", session, htmlToReturn, Request, Response);
        //            }
        //        }
        //    }
        //}
        //'--per i documenti generici con il parametro IdPfu passato


        // Metodo commentato da Claudio in quanto ha 0 riferimenti
        //public static void DocGenPermission_IdPfu(int IDDOC, string IdPfu, EprocNext.Session.ISession session, EprocResponse htmlToReturn, HttpRequest Request, HttpResponse Response)
        //{
        //    string strSQL = "";
        //    TSRecordSet? rs = null;
        //    string dcmDocPermission = "";
        //    string ip = getIpClient(Request);
        //    if (IDDOC != -1)
        //    {
        //        //'-- Se l'idpfu non � in sessione, la richiesta � di backoffice e l'ip non � autorizzato a tale operativit�, ti butto fuori
        //        //'-- 127.0.0.1@172.16.3.37@172.16.3.35
        //        if (string.IsNullOrEmpty(session["idpfu"]) && Strings.InStr(1, ApplicationCommon.Application["ip-backoffice"], ip) == 0)
        //        {
        //            exitWithBlocco(" IP non autorizzato ad un accesso backoffice ", session, htmlToReturn, Response);
        //            throw new ResponseEndException(htmlToReturn.Out(), Response, "");
        //        }
        //        else
        //        {
        //            strSQL = "select isnull(dcmDocPermission,'') as dcmDocPermission from DOCUMENT, TAB_MESSAGGI where idmsg=" + CLng(IDDOC) + " and dcmitype=msgitype and dcmisubtype=msgisubtype";
        //            CommonDbFunctions cdb = new CommonDbFunctions();
        //            rs = cdb.GetRSReadFromQuery_(CStr(strSQL), CStr(ApplicationCommon.Application["ConnectionString"]));
        //            if (rs.RecordCount > 0)
        //            {
        //                dcmDocPermission = GetValueFromRS(rs.Fields["dcmDocPermission"]);
        //                if (dcmDocPermission != "")
        //                {
        //                    if (IdPfu != "")
        //                    {
        //                        CheckDocPermission(dcmDocPermission, IDDOC, "-10", "", session, htmlToReturn, Request, Response); //'-- -10  : stampa di un documento in backoffice via server
        //                    }
        //                    else
        //                    {
        //                        CheckDocPermission(dcmDocPermission, IDDOC, IdPfu, "", session, htmlToReturn, Request, Response);
        //                    }
        //                }
        //            }
        //        }
        //    }
        //}

        //'--per i nuovi documenti
        public static void DocPermission(HttpContext context, dynamic IDDOC, string TIPODOC, string param, eProcurementNext.Session.ISession session, EprocResponse htmlToReturn, HttpRequest Request, HttpResponse Response, int forzaEseguiDocPermission = 0)
        {
            eProcurementNext.Core.Pages.CTL_LIBRARY.functions.DocumentPermissionModel.DocPermission(context, IDDOC, TIPODOC, param, session, htmlToReturn, Request, Response, forzaEseguiDocPermission);

        }
        //'--controlla se l'utente in input ha il permesso di aprire il documento
        public static void CheckDocPermission(HttpContext context, string dcmDocPermission, dynamic IDDOC, dynamic IdPfu, string param, eProcurementNext.Session.ISession session, EprocResponse htmlToReturn, HttpRequest Request, HttpResponse Response, int forzaEseguiDocPermission = 0)
        {
            eProcurementNext.Core.Pages.CTL_LIBRARY.functions.DocumentPermissionModel.CheckDocPermission(context, dcmDocPermission, IDDOC, IdPfu, param, session, htmlToReturn, Request, Response, forzaEseguiDocPermission);


        }
        public static void exitWithBlocco(HttpContext context, string blocco, eProcurementNext.Session.ISession session, EprocResponse htmlToReturn, HttpResponse Response)
        {
            eProcurementNext.Core.Pages.CTL_LIBRARY.functions.DocumentPermissionModel.exitWithBlocco(context, blocco, session, htmlToReturn, Response);

        }
        public static void addLogAttach(HttpContext context, string motivo, eProcurementNext.Session.ISession session)
        {
            eProcurementNext.Core.Pages.CTL_LIBRARY.functions.DocumentPermissionModel.addLogAttach(context, motivo, session);
        }


    }
}
