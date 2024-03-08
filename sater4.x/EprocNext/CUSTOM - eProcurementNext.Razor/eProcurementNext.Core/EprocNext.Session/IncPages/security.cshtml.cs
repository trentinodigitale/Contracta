using eProcurementNext.Application;
using eProcurementNext.BizDB;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.Core.Storage;
using eProcurementNext.Security;
using eProcurementNext.Session;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System;
using System.Data.SqlClient;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.Core.Pages.CTL_LIBRARY.functions
{
    public class securityModel : PageModel
    {

        public const int TIPO_PARAMETRO_STRING = 1;
        public const int TIPO_PARAMETRO_INT = 2;
        public const int TIPO_PARAMETRO_FLOAT = 3;
        public const int TIPO_PARAMETRO_NUMERO = 4;
        public const int TIPO_PARAMETRO_DATA = 5;
        public const int SOTTO_TIPO_PARAMETRO_CUSTOM = 0;
        public const int SOTTO_TIPO_PARAMETRO_NESSUNO = 0;
        public const int SOTTO_TIPO_VUOTO = 0;
        public const int SOTTO_TIPO_PARAMETRO_TABLE = 1;
        public const int SOTTO_TIPO_PARAMETRO_PAROLASINGOLA = 1;
        public const int SOTTO_TIPO_PARAMETRO_SORT = 2;
        public const int SOTTO_TIPO_PARAMETRO_FILTROSQL = 3;
        public const int SOTTO_TIPO_PARAMETRO_TEXTAREA = 3;
        public const int SOTTO_TIPO_PARAMETRO_LISTANUMERI = 4;

        public const string key_sicurezza_disattiva_redirect = "sicurezza_disattiva_redirect";
        public const string key_sicurezza_esito_blocco = "sicurezza_esito_blocco";


        //private static string mp_strNomeCompleto;
        //private static string mp_strNomeFIle;
        //private static string mp_strDeleteFIle;
        private static string str_Drive = ApplicationCommon.Application["MAP_SHARE_ACCESS_FILE_DRIVE"];
        private static string str_UserName = ApplicationCommon.Application["MAP_SHARE_ACCESS_FILE_USERNAME"];
        private static string str_Pwd = ApplicationCommon.Application["MAP_SHARE_ACCESS_FILE_PWD"];
        private static string strCause = string.Empty;

        /// <summary>
        /// 
        /// </summary>
        /// <param name="nomeParametro">Nome del parametro (da GET o da POST) che si st� validando. O semplicemente un nome di variabile</param>
        /// <param name="valoreDaValidare">Valore che vogliamo validare per un controllo di sicurezza, probabile fonte : queryString o form</param>
        /// <param name="tipoDaValidare">Tipo di dati atteso
        ///     1 = String
        ///	    2 = Intero/Long 
        ///	    3 = Float,Double 
        ///	    4 = Un qualsiasi numero 
        ///	    5 = Una data
        /// </param>
        /// <param name="sottoTipoDaValidare">Se il tipoDaValidare � 1 (stringa), questo parametro indica che tipo di stringa di aspettiamo
        ///     * 1 = Formato table like, valori attesi : stringa compresa tra 1 e 100 caratteri e possiede solo caratteri minuscoli e maiuscoli, numeri e il caratteri underscore "_"
        ///     * 2 = Formato sort like, valori attesi  : decimali,caratteri dalla a alla z, underscore e virgole e spazi,
        ///     * 3 = Formato sql filter
        ///     * 4 = Formato che permette solo numeri e virgole
        /// </param>
        /// <param name="regExp">Se sottoTipoDaValidare � uguale a 0 e tipoDaValidare � uguale ad 1 andremo a validare il parametro valoreDaValidare rispetto all'espressione regolare contenuta in questo parametro.
        /// Valorizzare a stringa vuota se non serve usarla
        /// </param>
        /// <param name="obblig">Indica se campo obbligatorio
        ///     1 = parametro obbligatorio,
        ///     0 = parametro opzionale
        /// </param>
        /// <param name="session"></param>
        /// <param name="blackList"></param>
        /// <param name="httpContext"></param>
        /// <returns></returns>
        public static string validate(string nomeParametro, string valoreDaValidare, int tipoDaValidare, int sottoTipoDaValidare, string regExp, int obblig, HttpContext httpContext, eProcurementNext.Session.ISession session)
        {
            eProcurementNext.Application.IEprocNextApplication application = ApplicationCommon.Application;

            bool isAttacked = false;

            //'Se siamo non siamo in modalit� DEBUG (sviluppo) non validiamo il parametro
            if (!string.IsNullOrEmpty(application["debug-mode"]) && (application["debug-mode"].ToUpper() != "SI" || application["debug-mode"].ToUpper() != "TRUE" || application["debug-mode"].ToUpper() != "YES"))
            {
                var objSecurityLib = new Validation(ApplicationCommon.Configuration, httpContext, session);

                if (obblig == 0 && (IsEmpty(valoreDaValidare)) || string.IsNullOrEmpty(valoreDaValidare))
                {
                    return "";
                }

                isAttacked = objSecurityLib.validate(session, nomeParametro, valoreDaValidare.Trim(), tipoDaValidare, sottoTipoDaValidare, regExp);

                if (isAttacked)
                {
                    httpContext.Items.TryGetValue(key_sicurezza_disattiva_redirect, out object? sicurezza_disattiva_redirect);
                    if (Convert.ToInt32(sicurezza_disattiva_redirect) == 0)
                    {
                        //'Se è presente NOMEAPPLICAZIONE nell'application
                        string redirectLocation = "";

                        if (!string.IsNullOrEmpty(application["NOMEAPPLICAZIONE"]))
                        {
                            redirectLocation = "/" + application["NOMEAPPLICAZIONE"] + "/blocked.asp";
                        }
                        else
                        {
                            redirectLocation = $"{application["strVirtualDirectory"]}/blocked.asp";
                        }

                        throw new ResponseRedirectException(redirectLocation, httpContext.Response);
                    }
                    else
                    {
                        //'-- volutamente non azzero questa variabile all'inizio del metodo di validate perchè
                        //'-- deve passare ad 1 se almeno uno dei parametri chiamati in una pagina ha un blocco
                        httpContext.Items.Add("sicurezza_esito_blocco", 1);
                        return "Blocco per modifica del parametro " + nomeParametro;
                    }
                }
            }

            return "";
        }

        public static void traceAttack(string trace, eProcurementNext.Session.ISession session, HttpContext httpContext)
        {
            eProcurementNext.Application.IEprocNextApplication application = ApplicationCommon.Application;

            var objBlack = new BlackList();
            objBlack.addIp(objBlack.getAttackInfo(httpContext, session[SessionProperty.IdPfu], CStr(trace)), session, ApplicationCommon.Application.ConnectionString);

            //'Se è presente NOMEAPPLICAZIONE nell'application
            if (CStr(application["NOMEAPPLICAZIONE"]) != "")
            {
                throw new ResponseRedirectException("/" + application["NOMEAPPLICAZIONE"] + "/blocked.asp", httpContext.Response);
            }
            else
            {
                throw new ResponseRedirectException($"{application["strVirtualDirectory"]}/blocked.asp", httpContext.Response);
            }
        }

        public static void traceEventViewer(string mErrSource, string mErrDescription, int tipo)
        {
            var objTrace = new DbEventViewer(ApplicationCommon.Configuration);
            objTrace.traceEventInDB(tipo, mErrSource, mErrDescription);
        }

        public static string insertAccessBarrier(eProcurementNext.Session.ISession session, HttpContext context)
        {


            string guid = "";

            TabManage objDB = new TabManage(ApplicationCommon.Configuration);
            if (IsEmpty(session["IdPfu"]))
            {
                session["IdPfu"] = -20;
            }
            string strSQL = "select newid() as guid";
            CommonDbFunctions cdf = new CommonDbFunctions();
            TSRecordSet rs = cdf.GetRSReadFromQuery_(strSQL, ApplicationCommon.Application.ConnectionString);

            rs.MoveFirst();

            guid = Replace(CStr(rs["guid"]), "{", "");

            guid = Replace(guid, "}", "");

            string legacyDB = "";

            eProcurementNext.Application.IEprocNextApplication application = ApplicationCommon.Application;

            //'--- SE ALLA PAGINA VIENE PASSATO IL PARAMETRO 'LEGACY_ACCESS' VUOL DIRE CHE LA SCRITTURA NELLA ACCESS BARRIER DEVE ESSERE FATTA SUL DATABASE INDICATO NELLA SYS 'DBNAME_PREV_VER'
            if (LCase(CStr(GetParamURL(context.Request.QueryString, "LEGACY_ACCESS"))) == "yes" && CStr(application["DBNAME_PREV_VER"]) != "")
            {
                legacyDB = CStr(application["DBNAME_PREV_VER"]) + "..";
            }


            Dictionary<string, object> Sqlparameters = new Dictionary<string, object>();
            Sqlparameters.Add("@guid", guid);
            Sqlparameters.Add("@idpfu", CInt(session["idpfu"]));
            Sqlparameters.Add("@session", CStr(session.SessionID));
            objDB.ExecSql(CStr("INSERT INTO " + legacyDB + "CTL_ACCESS_BARRIER([guid],[idpfu],[sessionid]) VALUES ( @guid, @idpfu, @session)"), ApplicationCommon.Application["ConnectionString"], null, Sqlparameters);


            //'-- Pulisco i vecchi record con data inserimento pi� vecchia di 60 secondi
            objDB.ExecSql(CStr("delete from " + legacyDB + "CTL_ACCESS_BARRIER where datediff(SECOND, data,getdate()) > 60"), ApplicationCommon.Application.ConnectionString);

            return guid;

        }

        public static int getAccessFromGuid(string guid)
        {
            int getAccessFromGuidRet = 0;

            var objDB = new TabManage(ApplicationCommon.Configuration);

			var sqlParams = new Dictionary<string, object?>();
			sqlParams.Add("@guid", guid);
            string strSql = "select idpfu from CTL_ACCESS_BARRIER with(nolock) where guid = @guid and datediff(SECOND, data,getdate()) <= 60";
            CommonDbFunctions cdf = new();
            TSRecordSet rs = cdf.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString, sqlParams);

            if (rs is not null && rs.RecordCount > 0)
            {
                getAccessFromGuidRet = CInt(rs["idpfu"]!);
				//'-- se trovo il guid cancello il record dopo averlo usato

                objDB.ExecSql(CStr("delete from CTL_ACCESS_BARRIER where guid = @guid"), ApplicationCommon.Application.ConnectionString, parCollection: sqlParams);
            }

            return getAccessFromGuidRet;
        }

        public static bool passWhiteList(string pagina, string parametro, string valore)
        {
            var sqlParams = new Dictionary<string, object?>();
            sqlParams.Add("@type", "SECURITY");
            sqlParams.Add("@REL_ValueInput", $"{pagina}-{parametro}");
            sqlParams.Add("@Output", valore);
            string strSQL = "select rel_type from CTL_Relations with(nolock) where rel_type = @type and REL_ValueInput = @REL_ValueInput and REL_ValueOutput = @Output";
            CommonDbFunctions cdf = new();
            TSRecordSet rs = cdf.GetRSReadFromQuery_(strSQL, ApplicationCommon.Application.ConnectionString, sqlParams);

            //'-- SE LA RELAZIONE HA RITORNATO RECORD VUOL DIRE CHE IL VALORE PASSATO FA PARTE DELLA WHITELIST, QUINDI E' CONSENTITO
            if (rs.RecordCount > 0)
            {
                return true;
            }
            return false;
        }

        public static void disattivaRedirect(HttpContext context)
        {
            context.Items.Add(key_sicurezza_disattiva_redirect, 1);
        }

        public static int isSecurityBlocked(HttpContext httpContext)
        {
            httpContext.Items.TryGetValue(key_sicurezza_esito_blocco, out object? value);
            return Convert.ToInt32(value);
        }

        /// <summary>
        /// FUNZIONE PER DOWNLOAD AND DELETE BIG FILE 
        /// </summary>
        /// <param name="strFilePath"></param>
        /// <param name="NomeFile"></param>
        /// <param name="strDeleteFile"></param>
        /// <param name="session"></param>
        /// <param name="HttpContext"></param>
        /// <param name="htmlToReturn"></param>
        /// <exception cref="ResponseRedirectException"></exception>
        public static void Redirect_2_DownLoadFile(string strFilePath, string NomeFile, string strDeleteFile, eProcurementNext.Session.ISession session, HttpContext HttpContext, EprocResponse htmlToReturn)
        {
            //var cdf = new CommonDbFunctions();
            //var accessGuid = insertAccessBarrier(session, HttpContext);  // non serve più

            //'--AGGIORNO SULLA RIGA DI ctl_access_barrier PATH E NOME FILE
            //const string strSql = @"UPDATE CTL_ACCESS_BARRIER
		          //                      SET  PKCE_code_challenge = @strFilePath, 
		          //                           PKCE_code_verifier = @NomeFile, 
		          //                           id_token = @strDeleteFile
		          //                  where GUID =  @accessGuid";

            //var sqlp = new Dictionary<string, object?>
            //{
            //    { "@strFilePath", strFilePath },
            //    { "@NomeFile", NomeFile },
            //    { "@strDeleteFile", strDeleteFile },
            //    { "@accessGuid", accessGuid }
            //};

            //cdf.Execute(strSql, ApplicationCommon.Application.ConnectionString, parCollection:sqlp);
            //string strVirtualDirectrory = CStr(ApplicationCommon.Application["APPLEGACY"]);

            //'-- FACCIO LA REDIRECT ALL APAGINA PER IL DOWNLOAD DEL FILE 
            //var strPage = $"/{strVirtualDirectrory}/ctl_library/functions/download.aspx?acckey={URLEncode(accessGuid)}";

            downloadFile(strFilePath, NomeFile, strDeleteFile, HttpContext, htmlToReturn);

            //throw new ResponseRedirectException(strPage, HttpContext.Response);
        }



        private static void downloadFile(string strFilePath, string NomeFile, string DeleteFile, HttpContext httpContext, IEprocResponse htmlToReturn)
        {
            DebugTrace dt = new DebugTrace();

            try
            {

                // --se mp_strNomeCompleto non inizia con una lettera allora faccio il MAP con un drive logico
                strCause = "MAP_SHARE_WITH_DRIVE";

                //string PercorsoDiRete = System.IO.Path.Combine(strFilePath, NomeFile);
                string PercorsoDiRete = strFilePath;
                dt.Write($"Path del file: {PercorsoDiRete}", "security.cshtml.cs", "downloadFile", "download");
                string directoryMap = net_utilsModel.MAP_SHARE_WITH_DRIVE(PercorsoDiRete);
                dt.Write($"Valore tornato da net_utilsModel.MAP_SHARE_WITH_DRIVE: {directoryMap}", "security.cshtml.cs", "downloadFile", "download");

                if (System.IO.File.Exists(PercorsoDiRete))
                {
                    httpContext.Response.ContentType = "application/zip";
                    httpContext.Response.Headers.TryAdd("content-disposition", "attachment; filename=" + PercorsoDiRete.Replace(" ", "_"));

                    LibDbAttach obj = new();
                    dt.Write($"Inizio fase di scrittura output", "security.cshtml.cs", "downloadFile", "download");
                    obj.writeToOutput(htmlToReturn, PercorsoDiRete, httpContext);
                    strCause = "apriamo il file";
                    // --SE RICHIESTO CANCELLO IL FILE CHE HO SCARICATO
                    strCause = "Cancello il file precedente se presente";
                    dt.Write($"Fine fase di scrittura output", "security.cshtml.cs", "downloadFile", "download");
                    if (DeleteFile.ToLower() == "delete")
                    {
                        if (CommonStorage.FileExists(PercorsoDiRete))
                        {
                            CommonStorage.DeleteFile(PercorsoDiRete);
                        }
                    }

                    // --TOLGO IL MAP DEL DRIVE LOGICO
                    dt.Write($"Unmapping unita di rete richiesto", "security.cshtml.cs", "downloadFile", "download");
                    net_utilsModel.MAP_SHARE_WITH_DRIVE(PercorsoDiRete, true);
                    dt.Write($"Unmapping unita di rete effettuato", "security.cshtml.cs", "downloadFile", "download");
                    //UnMapDrive(str_Drive);
                }
                else
                {
                    htmlToReturn.Write(PercorsoDiRete + " non esiste");
                    //response.end();
                    throw new ResponseEndException(htmlToReturn.Out(), httpContext.Response, PercorsoDiRete + " non esiste");
                }
            }
            catch (Exception ex)
            {
                dt.Write($"Richiamo gestione del trace errore", "security.cshtml.cs", "downloadFile", "download");
                // --SEGNALO L'Errore
                //traceError(sqlConn1, CStr(mp_idpfu), strCause + " -- " + ex.Message, httpContext.Request.Path);
                CommonDB.Basic.TraceErr(ex, ApplicationCommon.Application.ConnectionString);
                
            }

            // --PROVO A CHIUDERE LA CONNESSIONE UTILIZZATA PER IL LOG DELL'ERRORE
            
        }

       

    }
}

