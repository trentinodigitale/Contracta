using eProcurementNext.Application;
using eProcurementNext.BizDB;
using eProcurementNext.Session;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc.RazorPages;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.Core.Pages.CTL_LIBRARY.functions
{
    public class logModel : PageModel
    {
        public void OnGet()
        {
        }

        public static void Log(HttpContext httpContext, eProcurementNext.Session.ISession session)
        {
            eProcurementNext.Application.IEprocNextApplication application = ApplicationCommon.Application;

            string path = httpContext.Request.Path;

            string userIp = net_utilsModel.getIpClient(httpContext.Request);
            string paginaRichiesta = CStr(httpContext.GetServerVariable("PATH_INFO"));
            string paginaChiamante = CStr(httpContext.GetServerVariable("HTTP_REFERER"));
            string browserUsato = CStr(httpContext.GetServerVariable("HTTP_USER_AGENT"));

            if (string.IsNullOrEmpty(paginaRichiesta))
            {
                paginaRichiesta = path.ToString();
            }
            string queryString = CStr(httpContext.Request.QueryString);
            if (queryString.StartsWith("?", StringComparison.Ordinal))
                queryString = queryString.Substring(1);

            string typeForm = CStr(httpContext.Request.ContentType);

            string sessionID = "";
            if (session != null)
            {
                sessionID = CStr(session.SessionID); //.Replace("'", "''");
            }

            string ipServer = CStr(httpContext.GetServerVariable("LOCAL_ADDR"));
            //string ipServer = CStr(httpContext.Connection.LocalIpAddress);


            //string sessionFixation = CStr(session["AFLINKFIXATION"]);
            string fixationUtente = CStr(httpContext.Request.Cookies["AFLINKFIXATION"]);


            string idpfu = "-20";
            string strForm = "";
            string strSql = "";


            if (session != null && !String.IsNullOrEmpty(CStr(session[SessionProperty.IdPfu])))
            {
                idpfu = CStr(session[SessionProperty.IdPfu]);
            }

            //'-- Se sul cliente si è scelto di non memorizzare i form, così da non salvare dati sensibili dell'utente



            if (IsEmpty(application["DISATTIVA_LOG_DEI_FORM"]) || LCase(application["DISATTIVA_LOG_DEI_FORM"]) == "no")
            {
                //' Se sto provenendo da un cambio password non memorizzo il form (per non mettere nel log la password in chiaro)
                if (!UCase(CStr(httpContext.Request.QueryString)).Contains("DOCUMENT=CHANGE_PWD", StringComparison.Ordinal))
                {
                    //'Controllo se si stà effettuando un upload prima di controllare
                    //' l'accesso al form nei casi in cui si effettua un upload annullerebbe l'invio dell'allegato
                    if (LCase(typeForm).Contains("x-www-form-urlencoded", StringComparison.Ordinal) || LCase(typeForm).Contains("text/plain", StringComparison.Ordinal))
                    {
                        foreach (var item in httpContext.Request.Form)
                        {
                            strForm = strForm + item.Key + "#=#" + item.Value + "#@#";
                        }
                    }
                    else
                    {
                        strForm = CStr(typeForm);
                    }
                }
            }

            string CTL_LOG_UTENTE = "CTL_LOG_UTENTE";
            if (session != null && CStr(session["sProfilo"]).Contains('@', StringComparison.Ordinal))
            {
                CTL_LOG_UTENTE = CStr(application["CTL_LOG_UTENTE"]);
            }

            if (!String.IsNullOrEmpty(CTL_LOG_UTENTE))
            {
                string strTmpIdMp = "";
                strTmpIdMp = CStr(session != null ? session[SessionProperty.IdMP] : "");
                //strTmpIdMp = strTmpIdMp.Replace("'", "''");

                string idIpNodo = CStr(application["IdIpNode"]);
                //if (!String.IsNullOrEmpty(idIpNodo)) idIpNodo = idIpNodo.Replace("'", "''");

                string COOKIE_BILANCIATORE = "";
                if (!String.IsNullOrEmpty(CStr(application["COOKIE_BILANCIATORE"])))
                {
                    COOKIE_BILANCIATORE = CStr(httpContext.Request.Cookies[application["COOKIE_BILANCIATORE"]]); //.Replace("'", "''");
                }

                strSql = "declare @DataOperazione as datetime " +
               "set @DataOperazione = getdate() " +
               "INSERT INTO " + CTL_LOG_UTENTE + " " +
               "(ip,idpfu,paginaDiArrivo,paginaDiPartenza,querystring,form,browserUsato,descrizione, sessionID) VALUES " +
               "('" + CStr(userIp).Replace("'","''") + "'," + idpfu + ",'" + paginaRichiesta.Replace("'","''") + "','" + Left(paginaChiamante.Replace("'","''"), 4000) + "'," +
               "'" + Left(queryString.Replace("'","''"), 4000) + "','" + strForm.Replace("'","''") + "','" + browserUsato.Replace("'","''") + "','IP-SERVER:" + ipServer.Replace("'","''") + "-SESSIONFIXATION:" + fixationUtente.Replace("'","''") + "-IDMP:" + CStr(strTmpIdMp).Replace("'","''") + "-NODO:" + CStr(idIpNodo).Replace("'", "''") + "-COOKIE_BILANCIATORE=" + COOKIE_BILANCIATORE.Replace("'", "''") + "','" + sessionID.Replace("'", "''") + "')" +
               " " +
               " UPDATE ProfiliUtente_DataLastOperation set Data = @DataOperazione where Idpfu = " + idpfu;


                var obj = new TabManage(ApplicationCommon.Configuration);
                obj.ExecSql(strSql, ApplicationCommon.Application.ConnectionString);

            }
        }
    }
}

