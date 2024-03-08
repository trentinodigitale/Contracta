using eProcurementNext.Application;
using eProcurementNext.BizDB;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.Razor;
using eProcurementNext.Session;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Configuration;
using static eProcurementNext.CommonDB.Basic;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.Core.Pages.CTL_LIBRARY.functions
{
    public class CheckSessionModel : PageModel
    {
        private ITabManage objDB;
        private eProcurementNext.Session.ISession _session;
        private eProcurementNext.Application.IEprocNextApplication _application;
        HttpContext _httpContext;
        net_utilsModel _net_utils;
        CommonDbFunctions cdf = new();

        public CheckSessionModel(
            ITabManage tabManage,
            eProcurementNext.Session.ISession session,
            eProcurementNext.Application.IEprocNextApplication application,
            HttpContext httpContext)
        {
            //_configuration = configuration;
            //_tabManage = tabManage;
            objDB = tabManage;
            _session = session;
            _application = application;
            _httpContext = httpContext;
            _net_utils = new net_utilsModel();
        }

        string GetServerVariable(string key)
        {
            return CStr(_httpContext.GetServerVariable(key));
        }

        public static void CheckSession(eProcurementNext.Session.ISession _session, HttpContext _httpContext, ref string motivo)
        {
            long dos_session_max_calls = 0;
            string dos_session_minute = String.Empty;
            //string dos_session_minute_calls = String.Empty;
            string dos_now_minute = String.Empty;

            int Check = 1;

            dynamic ip = net_utilsModel.getIpClient(_httpContext.Request);

            string paginaRichiesta = _httpContext.Request.Path;

            // recupero blacklist caricata nel GlobalAsa
            Dictionary<string, dynamic>? blacklist = new();
            try
            {
                blacklist = ApplicationCommon.Application["blacklist"];
            }
            catch (Exception ex)
            {
                blacklist = new();
                WriteToEventLog(ex.ToString(), TsEventLogEntryType.Warning);
            }

            //' Se l'ip non è presente nella blacklist
            if (blacklist != null && !blacklist.ContainsKey(ip))
            {

                //'--Se non si è loggato
                if (IsEmpty(_session[SessionProperty.IdPfu]) || CInt(_session[SessionProperty.IdPfu]) < -1)
                {
                    //'-- Se c'è -20 in sessione, quindi è stata invocata la pagina loginportale.asp,
                    //'-- e se c'è attivo il controllo delle pagina di loginPortale ( sys_pagine_loginportale)
                    //'-- controllo che la pagina che si sta tentando di aprire è tra quelle
                    //'-- autorizzate ad essere aperte dal portale ( quindi senza un reale login )

                    //var pagineLoginPortale = CStr(_application["PAGINE_LOGINPORTALE"]);
                    if (!string.IsNullOrWhiteSpace(ApplicationCommon.Application["PAGINE_LOGINPORTALE"]) && CInt(_session[SessionProperty.IdPfu]) == -20)
                    {
                        string[] vett = CStr(ApplicationCommon.Application["PAGINE_LOGINPORTALE"]).Split("@@@");
                        var found = false;

                        foreach (string x in vett)
                        {
                            if (x.Length < paginaRichiesta.Length)
                            {
                                if (paginaRichiesta.ToUpper().Contains(x.ToUpper(), StringComparison.Ordinal))
                                {
                                    found = true;
                                    break;
                                }
                            }
                            else
                            {
                                //'-- Se la pagina ,o la porzione di url, presente nella variabile X è contenuto nella pagina richiesta
                                if (x.ToUpper().Contains(paginaRichiesta.ToUpper(), StringComparison.Ordinal))
                                {
                                    found = true;
                                    break;
                                }
                            }
                        }

                        if (!found)
                        {
                            var objBlacklist2 = new BlackList();

                            //'-- Se non siamo in modalità di sviluppo aggiungiamo l'ip alla blacklist
                            if (!objBlacklist2.isDevMode())
                            {
                                objBlacklist2.addIp(objBlacklist2.getAttackInfo(_httpContext, _session[SessionProperty.IdPfu], "Tentativo di accesso con idpfu -20 a pagine non autorizzate.Vedi SYS_PAGINE_LOGINPORTALE "), _session, ApplicationCommon.Application.ConnectionString);
                            }

                            //'Se è presente NOMEAPPLICAZIONE nell'application
                            if (!string.IsNullOrEmpty(CStr(ApplicationCommon.Application["NOMEAPPLICAZIONE"])))
                            {
                                throw new ResponseRedirectException("/" + ApplicationCommon.Application["NOMEAPPLICAZIONE"] + "/blocked.asp", _httpContext.Response);
                            }
                            else
                            {
                                throw new ResponseRedirectException($@"{ApplicationCommon.Application["strVirtualDirectory"]}/blocked.asp", _httpContext.Response);
                            }

                            // questa riga non serve avendo generato un eccezione per il redirect 
                            //Response.End
                        }
                    }

                    //'-- Se la richiesta è di backoffice e l'ip non è autorizzato a tale operatività, ti butto fuori
                    if (!CStr(ApplicationCommon.Application["ip-backoffice"]).Contains(ip, StringComparison.Ordinal) && GetParamURL(_httpContext.Request.QueryString, "backoffice").ToUpper() == "YES")
                    {
                        motivo = "IDPFU negativo o vuoto. Se la richiesta è di backoffice e l'ip non è autorizzato a tale operatività, ti butto fuori";
                        ExitExpired(motivo, _httpContext, _session);
                    }

                    //'-- Se non si sta passando il parametro backoffice avendo in sessione l''idpfu -20 (ipfu di portale)
                    if (GetParamURL(_httpContext.Request.QueryString, "backoffice") != "yes" &&
                        (!IsEmpty(_session[SessionProperty.IdPfu]) && CInt(_session[SessionProperty.IdPfu]) != -20))
                    {
                        motivo = "IDPFU negativo o vuoto. Se non si sta passando il parametro backoffice avendo in sessione l'idpfu -20 (ipfu di portale)";
                        ExitExpired(motivo, _httpContext, _session);
                    }

                }
                else    //'-- se c'è una sessione viva
                {

                    //AntiFixationVerify()

                    //'-- Se l'ip del chiamante non corrisponde con l'ip che ha effettuato il login e non siamo in backoffice
                    if ((GetParamURL(_httpContext.Request.QueryString, "backoffice") != "yes" || !CStr(ApplicationCommon.Application["ip-backoffice"]).Contains(ip, StringComparison.Ordinal)) && !string.IsNullOrEmpty(_session["ip_login"]) && _session["ip_login"] != ip)
                    {
                        //'-- Se è attivo il meccanismo di controllo dell'ip di request rispetto all'ip di login
                        if (!IsEmpty(ApplicationCommon.Application["SESSION_IP"]) && CStr(ApplicationCommon.Application["SESSION_IP"]).ToUpper() == "YES")
                        {
                            _httpContext.Response.Clear();

                            //'Session.Abandon --> invaliderei anche la sessione dell'utente corretto

                            //'dim objBlacklist2
                            var objBlacklist2 = new BlackList();

                            //'-- Se non siamo in modalità di sviluppo aggiungiamo l'ip alla blacklist
                            if (!objBlacklist2.isDevMode())
                            {
                                objBlacklist2.addIp(objBlacklist2.getAttackInfo(_httpContext, _session[SessionProperty.IdPfu], "Session hijacking: Accesso tramite session ID (" + _session.SessionID + ") valido ma con ip non coincidente a quello di login"), _session, ApplicationCommon.Application.ConnectionString);
                            }

                            //'-- Essendo questa la sessione anche dell'utente realmente loggato e autorizzato
                            //'-- attivo il flag per segnalare un messaggio all'utente
                            if (string.IsNullOrEmpty(_session["SYSTEM_INFO"]))
                            {
                                _session["SYSTEM_INFO"] = "chiave_session_hacking";
                            }

                            //objBlacklist2 = null;

                            motivo = "Siamo in sessione ma l'IP del Chiamante è cambiato";
                            ExitExpired(motivo, _httpContext, _session, ip);
                        }
                    }
                }

                //'--------------------------------
                //'--- CONTROLLO ANTI D.O.S. ------
                //'--------------------------------

                //'-- 	1. Se sono arrivato qui vuol dire che sono autorizzato a navigare sull'applicazione
                //'--	2. Faccio il controllo solo se sono un ip non backoffice 

                if (!CStr(ApplicationCommon.Application["ip-backoffice"]).Contains(ip, StringComparison.Ordinal))
                {
                    if (!string.IsNullOrEmpty(CStr(ApplicationCommon.Application["SECURITY_DOS_CALLS"])))
                    {
                        dos_session_max_calls = CLng(ApplicationCommon.Application["SECURITY_DOS_CALLS"]);
                    }
                    else
                    {
                        dos_session_max_calls = 300;
                    }

                    dos_session_minute = CStr(_session["dos_minute"]);

                    // non usata
                    //dos_session_minute_calls = CStr(_session["dos_minute_call"]);

                    dos_now_minute = DateTime.Now.ToString("mm");

                    //'-- A rottura di chiave sul minuto
                    if (dos_session_minute != dos_now_minute)
                    {
                        _session["dos_minute"] = dos_now_minute;
                        _session["dos_minute_call"] = 0;
                    }
                    else
                    {
                        _session["dos_minute_call"] = CLng(_session["dos_minute_call"]) + 1L;
                    }

                    //'response.write "chiamate per minuto: " & cstr(session("dos_minute_call"))

                    if (CLng(_session["dos_minute_call"]) > dos_session_max_calls)
                    {
                        var objBlacklist2 = new BlackList();

                        //'-- Se non siamo in modalità di sviluppo aggiungiamo l'ip alla blacklist
                        if (!objBlacklist2.isDevMode())
                        {
                            objBlacklist2.addIp(objBlacklist2.getAttackInfo(_httpContext, _session[SessionProperty.IdPfu], "D.O.S. : Superato il numero massimo di invocazioni per minuto"), _session, ApplicationCommon.Application.ConnectionString);
                        }

                        //objBlacklist2 = null;

                        motivo = "Superato il numero massimo di invocazioni per minuto";
                        ExitDos(_httpContext, _session);
                    }
                }

                //'-------------------------------------
                //'--- FINE CONTROLLO ANTI D.O.S. ------
                //'-------------------------------------


                //'-----------------------------------------------------
                //'--- CONTROLLO PER ATTIVITA BLOCCANTI NON SUPERATE ---
                //'-----------------------------------------------------

                //'-- se non sono sulla check attivita
                //'-- se non sono sul viewer delle attivit�
                //'-- se non sono su un documento aperto dalla lista attivita ( parametro LO <> lista_attivita )
                //'-- e se ho un attività bloccante
                string PagineDaNonControllare = CStr(ApplicationCommon.Application["LISTA_ATTIVITA_PAGINEDANONCONTROLLARE"]);

                if (("###" + PagineDaNonControllare.ToString() + "###").Contains(CStr(paginaRichiesta).ToLower(), StringComparison.Ordinal))
                {
                    Check = 0;
                }

                if (Check == 1 && paginaRichiesta.ToLower() != "/checkattivita.asp" && paginaRichiesta.ToLower() != "/ctl_library/path.asp" && !_httpContext.Request.QueryString.ToString().ToUpper().Contains("LISTA_ATTIVITA", StringComparison.Ordinal) && CStr(_session["attivita_bloccanti"]) == "1" && GetParamURL(_httpContext.Request.QueryString, "lo")?.ToLower() != "lista_attivita")
                //if (Check == 1 && paginaRichiesta.ToLower() != $@"{ApplicationCommon.Application["strVirtualDirectory"]}/checkattivita.asp" && paginaRichiesta.ToLower() != $@"{ApplicationCommon.Application["strVirtualDirectory"]}/ctl_library/path.asp" && !_httpContext.Request.QueryString.ToString().ToUpper().Contains("LISTA_ATTIVITA") && CStr(_session["attivita_bloccanti"]) == "1" && GetParamURL(_httpContext.Request.QueryString, "lo")?.ToLower() != "lista_attivita")
                {

                    if (string.IsNullOrEmpty(GetParamURL(_httpContext.Request.QueryString, "lo")))
                    {
                        throw new ResponseRedirectException("/" + ApplicationCommon.Application["NOMEAPPLICAZIONE"] + "/CTL_LIBRARY/MessageBoxWin.asp?ML=yes&MSG=Prima di eseguire una qualsiasi operazione svolgere le attivita bloccanti elencate dopo il login&CAPTION=Stop&ICO=2", _httpContext.Response);
                    }
                    else
                    {
                        //'-- se è ad 1 vuol dire l'utente ha bypassato la checkattività, quindi ce lo rimando!
                        throw new ResponseRedirectException("/" + ApplicationCommon.Application["NOMEAPPLICAZIONE"] + "/checkattivita.asp", _httpContext.Response);
                    }
                }
            }
            else
            {
                //'Se è presente NOMEAPPLICAZIONE nell'application
                if (!string.IsNullOrEmpty(CStr(ApplicationCommon.Application["NOMEAPPLICAZIONE"])))
                {
                    throw new ResponseRedirectException("/" + CStr(ApplicationCommon.Application["NOMEAPPLICAZIONE"]) + "/blocked.asp", _httpContext.Response);
                }
                else
                {
                    throw new ResponseRedirectException($@"{ApplicationCommon.Application["strVirtualDirectory"]}/blocked.asp", _httpContext.Response);
                }

            }

            //'--------------------------------------------------------------------------
            //'-- CONTROLLO PER IMPEDIRE LE SESSIONI CONCORRENTI A PARITA' DI UTENZA ----
            //'--	 ( l'utente deve essere loggato e non deve avere il # nei profili -----
            //'--------------------------------------------------------------------------

            if (!IsEmpty(_session[SessionProperty.IdPfu]) && CInt(_session[SessionProperty.IdPfu]) > 0 && !CStr(_session["sProfilo"]).Contains("#", StringComparison.Ordinal))
            {
                //'-- Se l'utente loggato non ha nelle lettere di profilo il # ( carattere speciale associato al profilo SysAdmin che permette ad utenze di backoffice di effettuare login multipli su più postazioni, vedi HD )
                int IdPfu = CInt(_session[SessionProperty.IdPfu]);
                string SessionID = _session.SessionID;

                var strSql = "select idpfu,pfuSessionID,pfufunzionalita from profiliutente with(nolock) where idpfu = " + IdPfu;

                TSRecordSet? rs = null;
                try
                {
                    CommonDbFunctions cdf = new();
                    rs = cdf.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString);
                }
                catch (Exception ex)
                {

                    eProcurementNext.CommonDB.Basic.TraceErr(ex, ApplicationCommon.Application.ConnectionString);
                }

                //'-- Aggiorna in sessione pfufunzionalita
                _session["Funzionalita"] = GetValueFromRS(rs.Fields["pfuFunzionalita"]);
                //'-- Se non ci sono errori ( quindi è presente la colonna pfuSessionID )
                //'--	e la select ha ritornato record
                if (/*err.number = 0 &&*/ rs != null && rs.RecordCount > 0 && SessionID != GetValueFromRS(rs.Fields["pfuSessionID"]))
                {
                    //rs = null;
                    //objDB = null;
                    motivo = "La sessione è stata chiusa per un accesso a parità di utenza su di un altra postazione";
                    ExitMultiSession(_httpContext, _session);
                }

                //rs = null;
                //objDB = null;

                //'--- Superati tutti i controlli di sessione andiamo ad inserire/aggiornare il cookie last_operation
                var tecDate = antiFixationModel.getTecDate("T");
                _httpContext.Response.Cookies.Append("LASTOPERATION", tecDate);

            }

        }

        public void OnGet()
        {

        }

        public static void TraccioInBlackListIlblocco(string Motivo, HttpContext _httpContext, eProcurementNext.Session.ISession _session)
        {
            const int MAX_LENGTH_ip = 97;
            const int MAX_LENGTH_form = 1494;
            const int MAX_LENGTH_motivoBlocco = 3994;

            //'-- traccio le informazioni di sessione per comprendere il motivo dell'uscita
            string strQueryString = _httpContext.Request.QueryString.ToString();
            string cookie_value = CStr(_httpContext.Request.Cookies["AFLINKFIXATION"]).Replace("'", "''");
            string session_value = CStr(_session["AFLINKFIXATION"]).Replace("'", "''");
            string ipServer = CStr(_httpContext.GetServerVariable("LOCAL_ADDR")).Replace("'", "''");
            dynamic userIp = net_utilsModel.getIpClient(_httpContext.Request).Replace("'", "''");
            const string acapo = "\r\n";

            var info = " - ID _SESSIONE ASP = [" + CStr(_session.SessionID) + "]" + acapo;
            info = info + " - LOCAL_ADDR Application = [" + ipServer + "]" + acapo;
            info = info + " - REMOTE_ADDR Client = [" + userIp + "]" + acapo;
            info = info + " - IDPFU in mem = [" + CStr(_session[SessionProperty.IdPfu]) + "]" + acapo;
            info = info + " - Application SESSION_IP = [" + ApplicationCommon.Application["SESSION_IP"] + "]" + acapo;
            info = info + " - cookie AFLINKFIXATION = [" + cookie_value + "]" + acapo;
            info = info + " - session AFLINKFIXATION = [" + session_value + "]" + acapo;
            info = info + " - Pagina di Partenza = [" + CStr(_httpContext.GetServerVariable("HTTP_REFERER")).Replace("'", "''") + "]" + acapo;
            info = info + " - Pagina di Arrivo = [" + CStr(_httpContext.GetServerVariable("PATH_INFO")).Replace("'", "''") + "]" + acapo;

            string COOKIE_BILANCIATORE = "";

            if (!string.IsNullOrEmpty(CStr(ApplicationCommon.Application["COOKIE_BILANCIATORE"])))
            {
                COOKIE_BILANCIATORE = CStr(_httpContext.Request.Cookies[CStr(ApplicationCommon.Application["COOKIE_BILANCIATORE"])]);
            }

            info = info + " - COOKIE BILANCIATORE = [" + COOKIE_BILANCIATORE + "]";

            var sqlParams = new Dictionary<string, object?>()
            {
                { "@ip", TruncateMessage(net_utilsModel.getIpClient(_httpContext.Request), MAX_LENGTH_ip)},
                {"@queryString", strQueryString},
                {"@form", TruncateMessage(info, MAX_LENGTH_form)},
                { "@motivoBlocco",  TruncateMessage(Motivo, MAX_LENGTH_motivoBlocco)}
            };
            var strSql = "insert into CTL_blacklist ( [ip], [statoBlocco], [dataBlocco], [paginaAttaccata], [queryString], [idPfu], [form], [motivoBlocco]) ";
            strSql = strSql + " select @ip as [ip], '' as [statoBlocco], getdate() as [dataBlocco], 'CheckSession.inc' as [paginaAttaccata],  @queryString as [queryString], 0 as [idPfu], @form as [form], @motivoBlocco as [motivoBlocco]";

            //'response.write strSql
            CommonDbFunctions cdf = new();
            cdf.Execute(strSql, ApplicationCommon.Application.ConnectionString, parCollection: sqlParams);
        }

        public static void ExitExpired(dynamic Motivo, HttpContext httpContext, eProcurementNext.Session.ISession session, string ip = "")
        {

            TraccioInBlackListIlblocco(Motivo, httpContext, session);

            //'- FORZO L'USCITA DALLA SESSIONE
            MainGlobalAsa.SessionAbandon(httpContext, session);

        }

        public static void ExitDos(HttpContext httpContext, eProcurementNext.Session.ISession session)
        {
            try
            {
                var objDB = new TabManage(ApplicationCommon.Configuration);
                objDB.ExecSql("UPDATE ProfiliUtente SET pfuStato = 'block' where idpfu = " + CStr(CLng(session[SessionProperty.IdPfu])), ApplicationCommon.Application.ConnectionString);
            }
            catch { }

            //'- FORZO L'USCITA DALLA SESSIONE
            MainGlobalAsa.SessionAbandon(httpContext, session);

        }

        public static void ExitMultiSession(HttpContext httpContext, eProcurementNext.Session.ISession session)
        {
            TraccioInBlackListIlblocco("La sessione è stata chiusa per un accesso a parità di utenza su di un altra postazione", httpContext, session);

            //'- FORZO L'USCITA DALLA SESSIONE
            MainGlobalAsa.SessionAbandon(httpContext, session);

        }

        /// <summary>
        /// Verifica se il richiedente corrisponde ad un ip backoffice
        /// </summary>
        /// <param name="httpContext"></param>
        /// <returns></returns>
        public static bool IsIpBackOffice(HttpContext httpContext)
        {
            string ipBackoffice = CStr(ApplicationCommon.Application["ip-backoffice"]);
            var clientIp = net_utilsModel.getIpClient(httpContext.Request);
            if (!string.IsNullOrEmpty(ipBackoffice) && clientIp.GetType() == typeof(string))
            {
                clientIp = clientIp.ToLower();
                foreach (string ip in ipBackoffice.Split("@"))
                {
                    if (clientIp == ip)
                    {
                        return true;
                    }
                }
            }
            return false;
        }

        /// <summary>
        /// verifica se una pagina è libera dal controllo di sessione
        /// </summary>
        /// <param name="httpContext"></param>
        /// <returns></returns>
        public static bool IsFreePage(HttpContext httpContext)
        {
            // il controllo di sessione deve essere effettuato su ogni pagina richiesta
            // a meno che non sia presente nell'elenco delle pagine escluse dal controllo (definito nell'appsetting)

            string requestPage = httpContext.Request.Path.ToString().ToLower();
            IEnumerable<string?> pagesToExclude = SessionCommon.Configuration!.GetSection("CheckSessionExcludePages").AsEnumerable().ToList().Select(kv => kv.Value);

            foreach (string? page in pagesToExclude)
            {
                if (!string.IsNullOrEmpty(page))
                {
                    string tmpPage = ReplacePlaceholders(page).ToLower().Trim();
                    if (tmpPage.StartsWith("*", StringComparison.Ordinal))
                    {
                        tmpPage = tmpPage.Substring(1);
                    }
                    if (requestPage.EndsWith(tmpPage, StringComparison.Ordinal))
                    {
                        return true;
                    }
                }
            }

            return false;
        }

        /// <summary>
        /// la refresh della session deve essere saltata se la pagina richiesta è nell'elenco PagesNoRefreshSession definito nell'appsetting
        /// </summary>
        /// <param name="httpContext"></param>
        /// <returns></returns>
        public static bool IsNoRefreshSessionPage(HttpContext httpContext)
        {


            string requestPage = httpContext.Request.Path.ToString().ToLower();
            IEnumerable<string?> pagesToExcludeRefresh = SessionCommon.Configuration!.GetSection("PagesNoRefreshSession").AsEnumerable().ToList().Select(kv => kv.Value);

            foreach (string? page in pagesToExcludeRefresh)
            {
                if (!string.IsNullOrEmpty(page))
                {
                    string tmpPage = ReplacePlaceholders(page).ToLower().Trim();
                    if (tmpPage.StartsWith("*", StringComparison.Ordinal))
                    {
                        tmpPage = tmpPage.Substring(1);
                    }
                    if (requestPage.EndsWith(tmpPage, StringComparison.Ordinal))
                    {
                        return true;
                    }
                }
            }

            return false;
        }


        /// <summary>
        /// se la path è una pagina asp cerco di fare il refresh della session associata al token
        /// </summary>
        /// <param name="_session"></param>
        /// <param name="isAspPage"></param>
        /// <param name="hasAuthToken"></param>
        /// <param name="hasAnonToken"></param>
        /// <param name="tokenAuth"></param>
        /// <param name="tokenAnon"></param>
        /// <param name="requestedPath"></param>
        public static void TrySessionRefresh(eProcurementNext.Session.ISession _session, bool isAspPage, bool hasAuthToken, bool hasAnonToken, string? tokenAuth, string? tokenAnon, string requestedPath)
        {
            if (!isAspPage)
            {
                return;
            }

            bool refreshed;
            if (hasAuthToken && tokenAuth != null && _session.IsActive(tokenAuth))
            {
                _session.Load(tokenAuth);
                try
                {
                    refreshed = _session.Refresh();
                    if (refreshed)
                    {
                        _session.LastUpdatePath = requestedPath;
                    }
                }
                catch (Exception ex)
                {
                    refreshed = false;
                    eProcurementNext.CommonDB.Basic.TraceErr(ex, ApplicationCommon.Application.ConnectionString);
                }
                return;
            }

            if (hasAnonToken && tokenAnon != null && _session.IsActive(tokenAnon))
            {
                _session.Load(tokenAnon);
                try
                {
                    refreshed = _session.Refresh();
                    if (refreshed)
                    {
                        _session.LastUpdatePath = requestedPath;
                    }
                }
                catch (Exception ex)
                {
                    refreshed = false;
                    eProcurementNext.CommonDB.Basic.TraceErr(ex, ApplicationCommon.Application.ConnectionString);
                }
                return;
            }

        }

        public static bool CheckJWTToken(eProcurementNext.Authentication.JWT jwt, bool hasAuthToken, string? tokenAuth, bool isProd = true)
        {
            if (hasAuthToken && tokenAuth != null)
            {
                return jwt.ValidateCurrentToken(tokenAuth, isProd);
            }

            return false;

        }

    }
}

