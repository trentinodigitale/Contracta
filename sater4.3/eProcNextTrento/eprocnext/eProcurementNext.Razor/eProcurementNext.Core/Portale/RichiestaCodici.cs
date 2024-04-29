
using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.CtlProcess;
using eProcurementNext.Session;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;

namespace eProcurementNext.Portale
{
    public class RichiestaCodici
    {
        private string mp_StrMsg;
        private Session.Session mp_ObjSession;// '-- oggetto che contiene il vettore base con gli elementi della libreria
        private string mp_Suffix;
        private long mp_User;
        private string mp_Permission;
        //private string mp_strConnectionString
        private dynamic Request_QueryString;
        private IFormCollection? Request_Form;
        private string mp_strTable;//'-- nome della tabella di riferimento per la funzione
        private string mp_queryString;
        private string mp_Modello;//'--modello della richiesta
        private dynamic mp_Matrix;
        private string mp_ColObblig;//'--lista colonne obbligatorie
        private string mp_ColObbligOR;//'--lista colonne di cui almeno una deve essere valorizzata
        private long mp_IdAzi;// '--azienda su cui vado a salvare i riferimenti
        private long mp_IdAziPlant;// '--azienda su cui sono definite le plant
        private string mp_Filter;
        public IConfiguration configuration;
        private HttpContext _context;
        private eProcurementNext.Session.ISession _session;
        CommonDbFunctions cdf = new();

        public RichiestaCodici(HttpContext context, eProcurementNext.Session.ISession session)
        {
            //this.configuration = configuration;
            //this._accessor = accessor;
            this._context = context;
            this._session = session;
        }

        public void run(EprocResponse Response)
        {
            string se = "";
            Dictionary<string, string> JS = new();
            string strCause = "";

            //On Error GoTo Herr:
            try
            {
                //'-- recupero variabili di sessione
                strCause = "Run:InitLocal";
                InitLocal();

                strCause = "Run:RichiestaCodici";
                try
                {
                    mp_StrMsg = _RichiestaCodici();

                }
                catch (Exception ex)
                {
                    se = ex.Message;
                    mp_StrMsg = ApplicationCommon.CNV("Impossibile effettuarre la richiesta", _session) + " : " + Environment.NewLine + se;
                }

                //'-- nel caso si debba visualizzare un messaggio si inserisce lo script
                strCause = "Run:aggiungo js per msgbox";
                if (GetParamURL(Request_QueryString.ToString(), "NEWLAYOUT") == "1")
                {
                    if (!JS.ContainsKey("ExcecFunction"))
                    {
                        JS.Add("ExcecFunction", @"<script src=""../CTL_Library/jscript/ExecFunction.js""></script>");
                    }
                    Response.Write(JavaScript(JS));
                }
                else
                {
                    Response.Clear();
                    Response.Write("<br><br>");
                }

                strCause = "Run:visualizzo messaggio=" + mp_StrMsg;
                if (!(string.IsNullOrEmpty(mp_StrMsg)))
                {
                    if (GetParamURL(Request_QueryString, "NEWLAYOUT") == "1")
                    {
                        strCause = "Run:Response.Write mp_StrMsg";
                        //'Response.Write "prima di scrittura mp_StrMsg"
                        Response.Write(CStr(mp_StrMsg));
                        //'Response.Write "dopo di scrittura mp_StrMsg"
                    }
                    else
                    {
                        strCause = "Run:Response.Write ShowMessageBox";
                        Response.Write(ShowMessageBox(mp_StrMsg, ApplicationCommon.CNV("Attenzione", _session), ""));
                    }
                }
                else
                {
                    if (GetParamURL(Request_QueryString, "NEWLAYOUT") == "1")
                    {
                        strCause = "Run:cnv Richiesta inviata Correttamente";
                        Response.Write(ApplicationCommon.CNV("Richiesta inviata Correttamente", _session));
                    }
                    else
                    {
                        strCause = "Run:ShowMessageBox";
                        Response.Write(ShowMessageBox(ApplicationCommon.CNV("Richiesta inviata Correttamente", _session), ApplicationCommon.CNV("Info", _session), ""));
                    }
                }
                if (GetParamURL(Request_QueryString, "NEWLAYOUT") != "1")
                {
                    strCause = "Run:self.close()";
                    Response.Write(@"<script language=""javascript"">");
                    Response.Write("self.close();");
                    Response.Write("</script>");
                }
            }
            catch (Exception ex)
            {
                throw new Exception(strCause, ex);
            }
        }
        private void InitLocal()
        {
            string mp_RSConnectionString = "";
            //On Error Resume Next
            try
            {
                //mp_ObjSession = (Session.Session)_session

                mp_Suffix = CStr(_session[SessionProperty.SESSION_SUFFIX]);

                if (string.IsNullOrEmpty(mp_Suffix))
                {
                    mp_Suffix = "I";
                }
                // Request_QueryString = session(RequestQueryString)
                Request_QueryString = GetQueryStringFromContext(_context.Request.QueryString);

                //Request_Form = session(RequestForm)
                Request_Form = _context.Request.HasFormContentType ? _context.Request.Form : null;

                mp_User = CLng(_session[SessionProperty.SESSION_USER]);
                mp_Permission = CStr(_session[SessionProperty.SESSION_PERMISSION]);

                if (!string.IsNullOrEmpty(ApplicationCommon.Application.ConnectionString))
                {
                    mp_RSConnectionString = ApplicationCommon.Application.ConnectionString;
                }
                if (string.IsNullOrEmpty(mp_RSConnectionString))
                {
                    mp_RSConnectionString = ApplicationCommon.Application.ConnectionString;
                }

                mp_Modello = GetParamURL(Request_QueryString, "Modello");
            }
            catch
            {

            }
        }

        //'--effettua la richeista dei codici
        public string _RichiestaCodici()
        {
            //On Error GoTo Herr: 
            string strSql;
            bool CheckCondition;
            TSRecordSet rs;
            long idpfurichiesta = 0;

            string strCause = string.Empty;
            string strTable;

            string __RichiestaCodici = string.Empty;
            strTable = " aziende ";
            try
            {
                if (Trim(GetValueFromForm(Request_Form, "Table")) != "")
                {
                    strTable = Trim(GetValueFromForm(Request_Form, "Table"));
                }

                strSql = "select lngsuffisso,pfue_mail,azipartitaiva as iddoc,profiliutente.* from " + Strings.Replace(strTable, "'", "''") + " ,profiliutente,lingue " +
                    " where idazi=pfuidazi and pfuidlng=idlng";
                //'--controllo se l'utente esiste
                if (mp_Modello.Trim() == "RECUPEROLOGIN")
                {
                    if (Trim(GetValueFromForm(Request_Form, "AttribKey")) == "")
                    {
                        strSql = strSql + " and azipartitaiva='" + Strings.Replace(Trim(GetValueFromForm(Request_Form, "AttribKey")), "'", "''") + "' and left(pfue_mail, isnull( nullif (charindex(';',pfue_mail),0),8000)-1) ='" + Strings.Replace(Trim(GetValueFromForm(Request_Form, "EMailUtente")), "'", "''") + "'";
                    }
                    else
                    {
                        strSql = strSql + " and " + Trim(GetValueFromForm(Request_Form, "AttribKey")) + "='" + Replace(Trim(GetValueFromForm(Request_Form, Trim(GetValueFromForm(Request_Form, "AttribKey")))), "'", "''") + "' and left(pfue_mail, isnull( nullif (charindex(';',pfue_mail),0),8000)-1) ='" + Replace(Trim(GetValueFromForm(Request_Form, "EMailUtente")), "'", "''") + "'";
                    }
                }
                else
                {
                    if (Trim(GetValueFromForm(Request_Form, "AttribKey")) == "")
                    {
                        strSql = strSql + " and azilog='" + Strings.Replace(Trim(GetValueFromForm(Request_Form, "CodiceAccesso")), "'", "''") + "'  and azipartitaiva='" + Strings.Replace(Trim(GetValueFromForm(Request_Form, "PartitaIva")), "'", "''") + "' and pfulogin='" + Strings.Replace(Trim(GetValueFromForm(Request_Form, "Login")), "'", "''") + "'";

                    }
                    else
                    {
                        strSql = strSql + " and azilog='" + Strings.Replace(Trim(GetValueFromForm(Request_Form, "CodiceAccesso")), "'", "''") + "'  and " + Trim(GetValueFromForm(Request_Form, "AttribKey")) + "='" + Strings.Replace(Trim(GetValueFromForm(Request_Form, Trim(GetValueFromForm(Request_Form, "AttribKey")))), "'", "''") + "' and pfulogin='" + Strings.Replace(Trim(GetValueFromForm(Request_Form, "Login")), "'", "''") + "'";
                    }
                }

                strCause = "eseguo query = " + strSql + " and pfudeleted = 0";
                rs = cdf.GetRSReadFromQuery_(strSql + " and pfudeleted = 0", ApplicationCommon.Application.ConnectionString);

                if (rs.EOF && rs.BOF)
                {
                    CheckCondition = false;
                }
                else
                {
                    CheckCondition = true;
                    idpfurichiesta = CLng(rs["idpfu"]!);
                }

                //Randomize
                Random rand = new Random();
                if (CheckCondition)
                {
                    rs = cdf.GetRSReadFromQuery_("select DZT_ValueDef from lib_dictionary where dzt_name = 'SYS_PWD_TENTATIVI_LOGIN'", ApplicationCommon.Application.ConnectionString);
                    if (rs.RecordCount > 0)//'se � presente la sys (quindi l'attivit� di controllo dei tentativi sulla login � presente sul cliente)
                    {
                        //'-- Controllo se l'utenza � bloccata
                        rs = cdf.GetRSReadFromQuery_($@"select isnull(pfustato, '') as pfustato from profiliutente where idpfu = " + idpfurichiesta + "", ApplicationCommon.Application.ConnectionString);

                        if (UCase(Trim(CStr(rs["pfustato"]))) == "BLOCK")
                        {
                            __RichiestaCodici = ApplicationCommon.CNV("I dati inseriti sono riferiti ad un utenza bloccata, contattare il fornitore del servizio", mp_ObjSession);
                            //Exit function
                            return __RichiestaCodici;
                        }
                    }

                    if (Trim(mp_Modello) == "RECUPEROPWD")
                    {
                        strCause = "genero nuova pwd";

                        //'--genero nuova pwd
                        //'For i = 1 To 12
                        //'strNewPwd = strNewPwd & Chr(Asc("A") + Rnd())
                        //'    strNewPwd = strNewPwd & Chr(Asc("A") + (Int((25 - 1 + 1) * Rnd + 1)))
                        //
                        //
                        //'Next
                        //
                        //
                        //'--la setto sull'utente
                        //'strCause = "setto nuova pwd sull'utente = " & idpfurichiesta
                        //'objDB.ExecSql "update profiliutente set pfuPassword='" & strNewPwd & "' where idpfu=" & idpfurichiesta, mp_strConnectionString
                    }
                    //'--innesco processo per invio mail
                    eProcurementNext.CtlProcess.ClsElab obj = new ClsElab();
                    strCause = $"innesco processo=RECUPEROCODICI modello={mp_Modello}";

                    ELAB_RET_CODE vRetCode;
                    string msgTitle = string.Empty;
                    int msgIcon = 0;
                    string msgBody = string.Empty;
                    string strDescrRetCode = string.Empty;

                    vRetCode = obj.Elaborate(CStr(mp_Modello), "RECUPEROCODICI", idpfurichiesta, idpfurichiesta, ref strDescrRetCode, 1, ApplicationCommon.Application.ConnectionString);
                    if (vRetCode != ELAB_RET_CODE.RET_CODE_OK)
                    {
                        //'RichiestaCodici = strDescrRetCode

                        InitMessageProcess(CInt(vRetCode), strDescrRetCode, ref msgTitle, ref msgIcon, ref msgBody);
                        __RichiestaCodici = msgBody;
                    }
                    //'--cifro la pwd dell'utente
                    if (Trim(mp_Modello) == "RECUPEROPWD")
                    {
                        // '--cifro la pwd
                        // 'strCause = "cifro pwd"
                        // 'Dim CriptPwd As String
                        // 'Set obj = CreateObject("crdll.clscrdll")
                        // 'CriptPwd = obj.Cript(strNewPwd)
                        // 'Set obj = Nothing
                        //
                        // '--la setto sull'utente e setto che al primo login deve essere cambiata
                        // 'strCause = "update pwd cifrata"
                        // 'strSql = "update profiliutente set pfupassword='" & CriptPwd & "',pfuopzioni=stuff(pfuopzioni,6,1,'0') where idpfu=" & idpfurichiesta
                        // 'objDB.ExecSql strSql, mp_strConnectionString
                    }
                }
                else
                {
                    //'-- Se non ho trovato l'utente verifico prima se esiste con pfudeleted, altrimenti do il messaggio di utente non presente
                    strCause = $"eseguo query = {strSql} and pfudeleted = 1";
                    rs = cdf.GetRSReadFromQuery_($"{strSql} and pfudeleted = 1", ApplicationCommon.Application.ConnectionString);

                    if (rs.EOF && rs.BOF)
                    {
                        __RichiestaCodici = ApplicationCommon.CNV("utente non presente:impossbile effettuare la richiesta", _session);
                    }
                    else
                    {
                        __RichiestaCodici = ApplicationCommon.CNV("Operazione non consentita. Utente Cancellato", _session);
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception(strCause, ex);
            }

            return __RichiestaCodici;
        }

        //'-- prende in input il valore ritornato dall'elaborazione del processo
        //'-- e costruisce i parametri per visualizzare il messaggio all'utente
        //capire il tipo

        private void InitMessageProcess(int vRetCode, string strDescrRetCode, ref string msgTitle, ref int msgIcon, ref string msgBody)
        {
            string[] v;
            int i = 0;
            int c = 0;
            string[] v1;
            int i1 = 0;
            int c1 = 0;
            string strMsg = string.Empty;
            string testo = string.Empty;

            if (vRetCode == 1)
            {
                msgIcon = MSG_ERR;
                msgTitle = "Errore";
            }
            else
            {
                msgIcon = MSG_INFO;
                msgTitle = "Attenzione";
            }
            //'-- recupero il messaggio da visualizzare
            v = Strings.Split(strDescrRetCode, "#@#");
            c = v.Length - 1;

            for (i = 0; i <= c; i++)
            {
                testo = v[i];
                if (Strings.InStr(1, v[i], "~~") > 0)
                {
                    v1 = Strings.Split(strDescrRetCode, "~~");
                    c1 = v1.Length - 1;

                    for (i1 = 0; i <= c1; i1++)
                    {
                        if (Strings.Left(v1[i1], 7) == "@TITLE=")
                        {
                            //'-- recupero la caption del messaggio se presente
                            msgTitle = Strings.Mid(v1[i1], 8);
                        }
                        else if (Strings.Left(v1[i1], 6) == "@ICON=")
                        {
                            //'-- recupero l'icona se presente
                            msgIcon = CInt(Strings.Mid(v1[i1], 7));
                        }
                        else
                        {
                            testo = v1[i1];
                            strMsg = strMsg + ApplicationCommon.CNV(CStr(v1[i1]), _session) + " ";
                        }
                    }

                }
                else
                {
                    strMsg = strMsg + ApplicationCommon.CNV(CStr(testo), _session) + " ";
                }
            }

            msgBody = strMsg;
        }
    }
}