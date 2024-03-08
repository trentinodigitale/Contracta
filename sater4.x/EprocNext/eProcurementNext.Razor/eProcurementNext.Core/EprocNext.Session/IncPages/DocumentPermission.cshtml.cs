using eProcurementNext.Application;
using eProcurementNext.BizDB;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.Core.Pages.CTL_LIBRARY.functions.masterPageToolsModel;
using static eProcurementNext.Core.Pages.CTL_LIBRARY.functions.net_utilsModel;

namespace eProcurementNext.Core.Pages.CTL_LIBRARY.functions
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
            string strSQL = "";
            TSRecordSet? rs = null;
            string dcmDocPermission = "";

            string ip = getIpClient(Request);

            //'-- Se l'idpfu non è in sessione e l'ip non è autorizzato a tale operatività, ti butto fuori
            if (string.IsNullOrEmpty(CStr(session["idpfu"])) && Strings.InStr(1, ApplicationCommon.Application["ip-backoffice"], ip) == 0)
            {
                exitWithBlocco(context, " IP non autorizzato ad un accesso backoffice ", session, htmlToReturn, Response);
                throw new ResponseEndException(htmlToReturn.Out(), Response, "");
            }
       
            strSQL = "select isnull(DOC_DocPermission,'') as DOC_DocPermission , isnull( DOC_PosPermission , 0 ) as DOC_PosPermission from LIB_DOCUMENTS where DOC_ID='" + TIPODOC.Replace("'", "''") + "'";
            CommonDbFunctions cdb = new CommonDbFunctions();
            rs = cdb.GetRSReadFromQuery_(CStr(strSQL), CStr(ApplicationCommon.Application["ConnectionString"]));

            if (rs.RecordCount > 0)
            {
                if (CStr(GetValueFromRS(rs.Fields["DOC_PosPermission"])) != "0")
                {
                    if (Strings.Mid(CStr(session["Funzionalita"]), CInt(GetValueFromRS(rs.Fields["DOC_PosPermission"])), 1) == "0")
                    {
                        exitWithBlocco(context, "Non si possiede il permesso per accedere", session, htmlToReturn, Response);
                        throw new ResponseEndException(htmlToReturn.Out(), Response, "");
                    }
                }
                dcmDocPermission = GetValueFromRS(rs.Fields["DOC_DocPermission"]);
                if (CStr(dcmDocPermission) != "")
                {
                    if (string.IsNullOrEmpty(CStr(session["idpfu"])))
                    {
                        CheckDocPermission(context, dcmDocPermission, IDDOC, "-10", param, session, htmlToReturn, Request, Response, forzaEseguiDocPermission); //'-- -10  : stampa di un documento in backoffice via server
                    }
                    else
                    {
                        CheckDocPermission(context, dcmDocPermission, IDDOC, session["IdPfu"], param, session, htmlToReturn, Request, Response, forzaEseguiDocPermission);
                    }
                }
            }

            
	

        }
        //'--controlla se l'utente in input ha il permesso di aprire il documento
        public static void CheckDocPermission(HttpContext context, string dcmDocPermission, dynamic IDDOC, dynamic IdPfu, string param, eProcurementNext.Session.ISession session, EprocResponse htmlToReturn, HttpRequest Request, HttpResponse Response, int forzaEseguiDocPermission = 0)
        {
            // 'Sub CheckDocPermission( dcmDocPermission , IDDOC , IdPfu )	

            TSRecordSet? rs = null;
            string strSQL = "";

            //'response.write "test"
            //'response.end

            string ip = getIpClient(Request);
            string ipServer = CStr(ApplicationCommon.Application["ip-super-backoffice"]);
            //'-- se non � presenta la lista di ip super backoffice (cio� la lista di ip dei server che possono fare chiamate 
            //'-- all'applicazione senza avere problemi di privilege escalation) utilizzo gli ip-backoffice normali
            if (string.IsNullOrEmpty(ipServer))
            {
                ipServer = CStr(ApplicationCommon.Application["ip-backoffice"]);
            }
            //'-- Se l'idpfu non � in sessione, la richiesta � di backoffice e l'ip non � autorizzato a tale operativit�, ti butto fuori

            if (string.IsNullOrEmpty(CStr(session["idpfu"])) && Strings.InStr(1, ApplicationCommon.Application["ip-backoffice"], ip) == 0)
            {
                exitWithBlocco(context, " IP non autorizzato ad un accesso backoffice ", session, htmlToReturn, Response);
                throw new ResponseEndException(htmlToReturn.Out(), Response, "");
            }
            else
            {
                //'-- se l'ip del chiamante � un super-backoffice non chiamo le stored di controllo
                if (InStrVb6(1, ipServer, ip) == 0 || forzaEseguiDocPermission == 1)
                {
                    if (string.IsNullOrEmpty(CStr(IdPfu)))
                    {
                        IdPfu = "-10";
                    }
                    if (string.IsNullOrEmpty(param))
                    {
                        strSQL = " exec " + dcmDocPermission + " " + IdPfu + " , '" + CStr(IDDOC).Replace("'", "''") + "'";
                    }
                    else
                    {
                        strSQL = " exec " + dcmDocPermission + " " + IdPfu + " , '" + CStr(IDDOC).Replace("'", "''") + "' , '" + param.Replace("'", "''") + "'";

                    }
                    if (!string.IsNullOrEmpty(GetParamURL(Request.QueryString.ToString(), "sectest")))
                    {
                        htmlToReturn.Write(strSQL);
                        throw new ResponseEndException(htmlToReturn.Out(), Response, "");
                    }

                    CommonDbFunctions cdb = new CommonDbFunctions();
                    try
                    {
                        rs = cdb.GetRSReadFromQuery_(strSQL, ApplicationCommon.Application["ConnectionString"]);
                    }
                    catch
                    {

                    }
                    if (rs != null && rs.RecordCount == 0)
                    {
                        exitWithBlocco(context, strSQL, session, htmlToReturn, Response);
                        throw new ResponseEndException(htmlToReturn.Out(), Response, "");
                    }
                }
            }


        }
        public static void exitWithBlocco(HttpContext context, string blocco, eProcurementNext.Session.ISession session, EprocResponse htmlToReturn, HttpResponse Response)
        {
            try
            {
                addLogAttach(context, "Permesso di accesso negato al documento. Motivazione: [[" + blocco + "]] ", session);
            }
            catch
            {

            }
            //'--se non ho il permesso faccio la redirect alla pagina informativa
            htmlToReturn.Clear();
            // '--setto il messaggio in session eper essere visualizzato
            session["MSG_ERROR"] = "ML=yes&MSG=permesso sul documento negato&CAPTION=Stop&ICO=2";

            //'--torno alla briciola di pane precedente
            popBreadCrumb("../../", session, Response);

            throw new ResponseRedirectException(ApplicationCommon.Application["strVirtualDirectory"] + "/home/main.asp?lo=base&GROUPS_NAME=" + CStr(session["GROUPS_NAME"]), Response);

            //'response.write "<strong>Accesso bloccato. Non si &egrave; autorizzati ad accedere al documento richiesto</strong>"
            //'response.write "<script>"
            //'response.write "window.history.back();"
            //'response.write "</script>"

            //'-- nel metodo popBreadCrumb viene effettuata una redirect. non dovrei arrivare a questa response.end � messa qui solo per sicurezza per non far proseguire la pagina in caso di errore
            throw new ResponseEndException(htmlToReturn.Out(), Response, "");

            throw new ResponseEndException(htmlToReturn.Out(), Response, "");

        }
        public static void addLogAttach(HttpContext context, string motivo, eProcurementNext.Session.ISession session)
        {
            BlackList objBlacklist2 = new BlackList();
            //'-- Se non siamo in modalit� di sviluppo aggiungiamo l'ip alla blacklist
            //'If (Not objBlacklist2.isDevMode(ObjSession)) Then

            objBlacklist2.addIp(objBlacklist2.getAttackInfo(context, CStr(session["IdPfu"]), CStr(motivo)), session, ApplicationCommon.Application["ConnectionString"]);

            // 'end if

            //'response.write motivo
            //'RESPONSE.END
        }


    }
}
