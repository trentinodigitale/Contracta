using eProcurementNext.Application;
using eProcurementNext.BizDB;
using eProcurementNext.CommonDB;
using eProcurementNext.Session;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.Razor.Pages.CTL_LIBRARY.functions
{
    public class trace_in_log_utenteModel : PageModel
    {
        //'--Versione=1&data=2013-05-13&Attvita=43033&Nominativo=Leone
        //
        //'-- typeMessage : Intero, Contiene il tipo di trace :
        //'--						0: Errore
        //'--						1: Info
        //'--						2: Warning
        //'--						3: Esito di un operazione
        //'-- chiamante   : Stringa. Fonte della trace ( ad es. 'invio documento', 'invio offerta', etc )
        //'-- messaggio   : Stringa. Descrizione della trace. ad es. Errore nell'invio dell'offerta aperta

        public static CommonDbFunctions cdf = new();

        public static void traceInLogUtente(dynamic typeMessage, dynamic chiamante, dynamic messaggio, HttpContext httpContext, eProcurementNext.Session.ISession session)
        {
            eProcurementNext.Application.IEprocNextApplication application = ApplicationCommon.Application;

            string userIp = net_utilsModel.getIpClient(httpContext.Request);
            string paginaRichiesta = Replace(CStr(httpContext.GetServerVariable("PATH_INFO")), "'", "''");
            string paginaChiamante = Replace(CStr(httpContext.GetServerVariable("HTTP_REFERER")), "'", "''");
            string browserUsato = Left(Replace(CStr(httpContext.GetServerVariable("HTTP_USER_AGENT")), "'", "''"), 1000);

            //string paginaRichiesta = CStr(httpContext.Request.Path);
            //string paginaChiamante = CStr(httpContext.Request.Headers.Referer);
            //string browserUsato = CStr(httpContext.Request.Headers.UserAgent);


            //string sessionID = (session != null) ? session.SessionID : "";

            string sessionID = Replace(CStr(session.SessionID), "'", "''");
            string CTL_LOG_UTENTE = "CTL_LOG_UTENTE";
            if (CStr(session["sProfilo"]).Contains("@", StringComparison.Ordinal))
            {
                CTL_LOG_UTENTE = application["CTL_LOG_UTENTE"];
            }

            if (!String.IsNullOrEmpty(CTL_LOG_UTENTE))
            {
                string ipServer = Replace(CStr(httpContext.GetServerVariable("LOCAL_ADDR")), "'", "''"); ;

                string sessionFixation = Replace(CStr(session["AFLINKFIXATION"]), "'", "''"); ;
                string? AFLINKFIXATIONCookie;
                string fixationUtente = "";
                if (httpContext.Request.Cookies.TryGetValue("AFLINKFIXATION", out AFLINKFIXATIONCookie))
                {
                    fixationUtente = Replace(CStr(AFLINKFIXATIONCookie), "'", "''"); ;

                }

                string idpfu = "-20";

                string typeTrace = "";
                switch (typeMessage)
                {
                    case 0:
                        typeTrace = "TRACE-ERROR";
                        idpfu = "-1";
                        break;
                    case 1:
                        typeTrace = "TRACE-INFO";
                        break;
                    case 2:
                        typeTrace = "TRACE-WARNING";
                        break;
                    case 3:
                        typeTrace = "TRACE-ESITO";
                        break;
                    default:
                        typeTrace = "TRACE-INFO";
                        break;
                }

                string strSqlLog = "";

                if (!String.IsNullOrEmpty(CStr(session[SessionProperty.IdPfu])))
                {
                    idpfu = CStr(session[SessionProperty.IdPfu]);
                }

                var sqlParams = new Dictionary<string, object?>
                {
                    { "@userIp", userIp },
                    { "@idpfu", CInt(idpfu) },
                    { "@paginaRichiesta", paginaRichiesta },
                    { "@paginaChiamante", Left(paginaChiamante, 4000) },
                    { "@typeTrace", typeTrace },
                    { "@messaggio", messaggio },
                    { "@browserUsato", browserUsato },
                    { "@ipServer", $"IP-SERVER:{ipServer}-SESSIONFIXATION:{fixationUtente}" },
                    { "@sessionID", $"{sessionID}-{sessionFixation}" }
                };
                strSqlLog = @"INSERT INTO CTL_LOG_UTENTE 
                            (ip,idpfu,datalog,paginaDiArrivo,paginaDiPartenza,querystring,form,browserUsato,descrizione,sessionID) VALUES 
                            (@userIp, @idpfu, getDate(), @paginaRichiesta, @paginaChiamante, 
                            @typeTrace, @messaggio, @browserUsato, @ipServer, @sessionID)";

                var objLog = new TabManage(ApplicationCommon.Configuration);
                objLog.ExecSql(strSqlLog, ApplicationCommon.Application.ConnectionString, parCollection: sqlParams);
            }
        }

        public static void TraceLogSPID(string cf, string status, string errorCode, HttpContext httpContext, eProcurementNext.Session.ISession session)
        {
            string idLogSpid = CStr(session["idLogSpid"]);

            if (idLogSpid == string.Empty)
            {
                //'-- l'errorCode "1" nella tabella dei messaggi SPID indica "Autenticazione corretta"
                if (!IsNumeric(errorCode))
                {
                    errorCode = "1";
                }

                string userIp = net_utilsModel.getIpClient(httpContext.Request);
                string ipServer = CStr(httpContext.Connection.LocalIpAddress);
                ipServer = CStr(httpContext.GetServerVariable("LOCAL_ADDR"));

                string sessionFixation = CStr(session["AFLINKFIXATION"]);

                string shibSessionIndex = CStr(httpContext.GetServerVariable("HTTP_SHIBSESSIONINDEX"));
                string authInstant = CStr(httpContext.GetServerVariable("HTTP_SHIBAUTHENTICATIONINSTANT"));
                string spid_code = CStr(httpContext.GetServerVariable("HTTP_SPIDCODE"));

                string shibIdentityProvider = CStr(httpContext.GetServerVariable("HTTP_SHIBIDENTITYPROVIDER"));

                if (spid_code == "")
                {
                    spid_code = CStr(session["SPID_SPIDCODE"]);
                }

                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@errorCode", CInt(errorCode));
                sqlParams.Add("@fixation", sessionFixation);
                sqlParams.Add("@ip", ipServer);
                sqlParams.Add("@ipuser", userIp);
                sqlParams.Add("@session", CStr(session.SessionID));
                sqlParams.Add("@status", status);
                sqlParams.Add("@shibIdentityProvider", shibIdentityProvider);
                sqlParams.Add("@shibSessionIndex", shibSessionIndex);
                sqlParams.Add("@cf", cf);
                sqlParams.Add("@spid_code", spid_code);
                sqlParams.Add("@authInstant", authInstant);
                string strSQL = "SET NOCOUNT ON" + Environment.NewLine;
                strSQL = strSQL + " INSERT INTO CTL_LOG_SPID (errorCode, aflinkFixation, ipServer, ipChiamante, AspSessionID, status, HTTP_SHIBIDENTITYPROVIDER, HTTP_SHIBSESSIONINDEX, HTTP_FISCALNUMBER, HTTP_SPIDCODE, IssueInstant)" + Environment.NewLine;
                strSQL = strSQL + "	VALUES (@errorCode, @fixation, @ip, @ipuser, @session, @status, @shibIdentityProvider, @shibSessionIndex, @cf, @spid_code, @authInstant)" + Environment.NewLine;
                strSQL = strSQL + " SELECT SCOPE_IDENTITY() as idLogSpid";

                //'response.write strSQL    
                //'response.end             

                var rsTmp = cdf.GetRSReadFromQuery_(strSQL, ApplicationCommon.Application.ConnectionString, sqlParams);

                if (rsTmp.RecordCount > 0)
                {
                    rsTmp.MoveFirst();
                    idLogSpid = CStr(rsTmp["idLogSpid"]);

                    //'-- commento questo step per far scrivere sempre nel log
                    //'session["idLogSpid"] = idLogSpid
                }
                else
                {
                    int idpfu = -20;

                    if (CStr(session[SessionProperty.IdPfu]) != "")
                    {
                        idpfu = CStr(session[SessionProperty.IdPfu]);
                    }

                    strSQL = "UPDATE CTL_LOG_SPID " + Environment.NewLine;
                    strSQL = strSQL + "		SET status = '" + status.Replace("'", "''") + "'" + Environment.NewLine;
                    strSQL = strSQL + "			,idPfu = " + CStr(CLng(idpfu)) + Environment.NewLine;
                    strSQL = strSQL + " WHERE id = " + CStr(CLng(idLogSpid));

                    var obj = new TabManage(ApplicationCommon.Configuration);
                    obj.ExecSql(strSQL, ApplicationCommon.Application.ConnectionString);
                }
            }
        }

        public void OnGet()
        {
        }
    }
}
