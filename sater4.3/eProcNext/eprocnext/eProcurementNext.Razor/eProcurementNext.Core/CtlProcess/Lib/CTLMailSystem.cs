using Chilkat;
using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.Core.Storage;
using System.Data.SqlClient;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;
using static eProcurementNext.CtlProcess.Basic;

namespace eProcurementNext.CtlProcess
{
    internal class CtlMailSystem : ProcessBase // IProcess
    {
        private Dictionary<string, string> mp_collParameters = new Dictionary<string, string>();
        private const string MODULE_NAME = "CtlProcess.CtlMailSystem";

        private string mp_strTypeDoc = string.Empty;
        private string mp_strKeyDoc = string.Empty;

        string strAbortOnError = string.Empty;

        readonly DebugTrace dt = new();

        string m_LoginMethod = string.Empty; //(XOAUTH2, LOGIN)
        string m_JsonToken = string.Empty;
        DateTime m_DateUpdateToken;
        int m_FrequencyUpdateToken = -1;
        string m_ClientId = string.Empty;
        string m_ClientSecret = string.Empty;
        string m_TokenEndpoint = string.Empty;

        //' parametri
        //'QUERY_GETUSERS_DEST#=#select * from DASHBOARD_VIEW_RDA_ONLY_INAPPROVE,lingue where pfuidlng=idlng and rda_id=65878
        //'                       se la query contenuta in QUERY_GETUSERS_DEST contiene la colonna MAIL_FROM_CONFIG si recupererà
        //'                       il suo valore per inviare le email da mittenti dinamici, recuperato/recuperati per l'appunto da questa colonna
        //'MAIL_FILE_NAME#=#RDA.html
        //'OBJECT_MAIL#=#Nuova RDA in approvazione
        //'MAIL_FROM#=#s.ferraro@afsoluzioni.it
        //'ABORT_ON_ERROR#=#1
        //
        //'URL_FILE#=# è la pagina html da inviare come allegato (http://localhost/application/report/stampafatture.asp)
        //'           nel caso delle stampe dei documenti l'url deve essere del tipo http://.....?IDDOC=<ID_DOC>&TYPEDOC=<TYPE_DOC>&LanguageSuffix=<LNG_DOC>
        //'QUERY_ATTACH#=# opzionale se valorizzata è la query per recuperare gli attach del documento deve avere una colonna ATTACH
        //'-- BODY_URL_FILE#=# se è presente utilizza l'output dell'url come body
        //'QUERY_GETUSERS_DEST#=#select * from DASHBOARD_VIEW_RDA_ONLY_INAPPROVE,lingue where pfuidlng=idlng and rda_id=65878#@#MAIL_FILE_NAME#=#RDA.html#@#OBJECT_MAIL#=#Nuova RDA in approvazione
        //'VIEW#=#nomeVista  --- Nome della vista dal quale prendere i dati dell'email
        //'MAIL_KEY_ML#=#chiaveMultilinguismo ----- chiave nel multilinguismo alla quale è associato il template mail
        //'URL_FILE_EXT -- usato per indicare che tipo di estensione deve avere il file da allegare alla mail
        //'URL_FILE_NAME -- usato per indicare il nome da assegnare al file che viene allegato alla mail

        const string MAIL_FILE_NAME = "MAIL_FILE_NAME";
        const string OBJECT_MAIL = "OBJECT_MAIL";
        const string QUERY_GETUSERS_DEST = "QUERY_GETUSERS_DEST";
        const string MAIL_FROM = "MAIL_FROM";
        const string ABORT_ON_ERROR = "ABORT_ON_ERROR";
        const string USE_MITT = "USE_MITT";
        const string view = "VIEW";
        const string MAIL_KEY_ML = "MAIL_KEY_ML";
        const string QUERY_ATTACH = "QUERY_ATTACH";
        const string URL_FILE = "URL_FILE";
        const string BODY_URL_FILE = "BODY_URL_FILE";
        const string URL_FILE_EXT = "URL_FILE_EXT";
        const string URL_FILE_NAME = "URL_FILE_NAME";

        int mp_Idpfu = 0;
        int mp_NumRetry = 0;

        private int iTimeout = -1;
        SqlTransaction? trans = null!;

        private readonly CommonDbFunctions cdf = new();

        public override ELAB_RET_CODE Elaborate(string strDocType, dynamic strDocKey, long lIdPfu, string strParam, ref string strDescrRetCode, dynamic? vIdMp = null, dynamic? connection = null, SqlTransaction? transaction = null, int timeout = -1)
        {
            ELAB_RET_CODE ret = ELAB_RET_CODE.RET_CODE_ERROR;
            int statusMail = 0;
            int NumRetry = 0;

            string strCause = string.Empty;

            trans = transaction;
            SqlConnection? cnLocal = null!;
            iTimeout = timeout;

            strDescrRetCode = string.Empty;
            mp_Idpfu = CInt(lIdPfu);

            mp_strTypeDoc = strDocType;
            mp_strKeyDoc = CStr(strDocKey);

            try
            {
                if (vIdMp is null)
                {
                    strDescrRetCode = "Parametro MarketPlace non valorizzato";
                    GoToFine(cnLocal, transaction, statusMail, NumRetry, CStr(strDocKey));
                    return ret;
                }

                //' Apertura connessione
                strCause = "Apertura connessione al DB";

                // setta la connessione
                cnLocal = SetConnection(connection, cdf);

                if (!string.IsNullOrEmpty(GetParamValue("TIMEOUT")))
                {
                    iTimeout = CInt(GetParamValue("TIMEOUT")!);
                }

                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                //' STEP 1 --- legge i parametri necessari
                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                strCause = "Lettura dei parametri che determinano le azioni";
                bool bOk = GetParameters(strParam);

                if (!bOk)
                {
                    GoToFine(cnLocal, transaction, statusMail, NumRetry, CStr(strDocKey));
                    return ret;
                }

                //'-- legge il numero massimo di retry dalla tabella dei parametri CTL_Parametri
                string sNumRetry = string.Empty;

                //On Error Resume Next
                //err.Clear

                sNumRetry = Email.Basic.GetCTLParam(cnLocal, transaction, "CTL_Mail_System", "SendMail", "NumRetry");

                int.TryParse(sNumRetry, out mp_NumRetry);

                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                //' STEP 5 --- gestione della mail
                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                TSRecordSet rs;
                string? strFrom = string.Empty;
                string strMailObj = string.Empty;
                string status = string.Empty;
                string InOut = string.Empty;
                string strMailTo = string.Empty;

                statusMail = 0;

                NumRetry = 0;

                //' -- accede alla CTL_Mail_System

                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@DocKey", CInt(strDocKey));

                rs = cdf.GetRSReadFromQueryWithTransaction("select *  from CTL_Mail_System with (nolock) where id= @DocKey", cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);

                if (rs.EOF && rs.BOF)
                {
                    GoToFine(cnLocal, transaction, statusMail, NumRetry, CStr(strDocKey));
                    return ret;
                }

                //'-- se ha trovato il record
                rs.MoveFirst();

                strFrom = CStr(rs["MailFrom"]);


                if (strFrom == null)
                    throw new Exception("MailFrom NULL da CTL_Mail_System");

                strMailObj = Trim(CStr(rs["MailObj"]));

                status = Trim(CStr(rs["Status"]));
                InOut = Trim(CStr(rs["InOut"]));

                NumRetry = CInt(rs["NumRetry"]!);

                dt.Write("CTLMailSystem riga 226");

                //'-- se non è una mail in uscita non la manda
                if (InOut != "OUT")
                {
                    ret = ELAB_RET_CODE.RET_CODE_OK;
                    GoToFine(cnLocal, transaction, statusMail, NumRetry, CStr(strDocKey));
                    return ret;
                }

                //'-- se la mail è in errore ed ha già provato 10 volte non la manda
                if (status == "Error" && NumRetry > mp_NumRetry)
                {
                    ret = ELAB_RET_CODE.RET_CODE_OK;
                    GoToFine(cnLocal, transaction, statusMail, NumRetry, CStr(strDocKey));
                    return ret;
                }

                //'-- se manca la colonna con la mail non la manda
                if (string.IsNullOrEmpty(strMailObj))
                {
                    GoToFine(cnLocal, transaction, statusMail, NumRetry, CStr(strDocKey));
                    return ret;
                }

                //'-- scarica l'allegato in un file EML che sarebbe la mail
                string strPath = string.Empty;
                string strFileAttach = string.Empty;

                strPath = ConfigurationServices.GetKey("ApplicationContext:PathFolderAllegati", "")!;

                if (string.IsNullOrEmpty(strPath))
                {
                    string strSqlLog = "select dzt_valuedef from lib_dictionary with (nolock) where dzt_name = 'SYS_PathFolderAllegati'";
                    strCause = "recupero il valore della sys configurata SYS_PathFolderAllegati";

                    rs = cdf.GetRSReadFromQueryWithTransaction(strSqlLog, cnLocal.ConnectionString, cnLocal, transaction, iTimeout);
                    if (!(rs.EOF && rs.BOF))
                    {
                        rs.MoveFirst();
                        strPath = CStr(rs["dzt_valuedef"]);
                    }
                }

                strCause = "Leggo la mail dal db, tramite la funzione SaveAttachToFile";

                dt.Write("CTLMailSystem riga 276 - prima di SaveAttachToFile. strMailObj = " + strMailObj);
                strFileAttach = SaveAttachToFile(cnLocal, transaction, strMailObj, strPath);
                dt.Write("CTLMailSystem riga 278 - dopo SaveAttachToFile");
                if (string.IsNullOrEmpty(strFileAttach))
                {
                    dt.Write("CTLMailSystem riga 281 - if (string.IsNullOrEmpty(strFileAttach))");
                    GoToFine(cnLocal, transaction, statusMail, NumRetry, CStr(strDocKey));
                    return ret;
                }

                if (!File.Exists(strFileAttach))
                {
                    dt.Write("CTLMailSystem riga 288 - if (!File.Exists(strFileAttach))");
                    GoToFine(cnLocal, transaction, statusMail, NumRetry, CStr(strDocKey));
                    return ret;
                }

                string verChilkat = string.Empty;
                MailMan mailman = new MailMan();
                Chilkat.Email email;


                bool success = false;
                string strError = string.Empty;
                dt.Write("CTLMailSystem riga 311 - prima di mailman.UnlockComponent");
                strCause = "Effettuo la UnlockComponent di Chilkat";
                mailman.UnlockComponent(Email.Basic.GetUnlockKey(ApplicationCommon.Configuration));

                dt.Write("CTLMailSystem riga 315 - prima di GetMailParam");
                strCause = "Richiamo la funzione GetMailParam()";
                //'-- legge i parametri tecnici per inviare l'email
                GetMailParam(cnLocal, transaction, strFrom, mailman);
                dt.Write("CTLMailSystem riga 318 - dopo SaveAttachToFile");
                //'-- carica l'email da spedire dal file che era nell'allegato
                email = new Chilkat.Email();

                strCause = "carica l'email da spedire prendendo il file EML";
                email.LoadEml(strFileAttach);
                dt.Write("CTLMailSystem riga 323 - prima di mailman.SendEmail(email)");

                string strErrore = string.Empty;
                //gestione office365 XOAUTH2
                if (m_LoginMethod == "XOAUTH2" && !string.IsNullOrEmpty(m_JsonToken))
                {
                    // vede se deve fare il refresh del token
                    if (IsDate(m_DateUpdateToken) && m_FrequencyUpdateToken > 0 && DateDiff("n", m_DateUpdateToken, DateTime.Now) >= m_FrequencyUpdateToken)
                    {
                        m_JsonToken = RefreshToken(m_JsonToken, m_TokenEndpoint, m_ClientId, m_ClientSecret);
                        //aggiorna il token in tabella
                        sqlParams.Clear();
                        sqlParams.Add("@JsonToken", m_JsonToken);
                        sqlParams.Add("@From", strFrom);
                        cdf.ExecuteWithTransaction("update CTL_CONFIG_MAIL set DateUpdateToken=getdate(), JsonToken = @JsonToken where alias=@From", cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);
                    }

                    //prova ad inviare
                    success = true;
                    if (!ConnectImapOffice365Smtp(m_JsonToken, mailman, email, out strErrore))
                    {
                        m_JsonToken = RefreshToken(m_JsonToken, m_TokenEndpoint, m_ClientId, m_ClientSecret);
                        // aggiorna il token in tabella
                        sqlParams.Clear();
                        sqlParams.Add("@JsonToken", m_JsonToken);
                        sqlParams.Add("@From", strFrom);
                        cdf.ExecuteWithTransaction("update CTL_CONFIG_MAIL set DateUpdateToken=getdate(), JsonToken = @JsonToken where alias=@From", cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);

                        // riprova a connettersi dopo avere aggiornato il token
                        // se adesso non funziona va in errore!!!!
                        if (!ConnectImapOffice365Smtp(m_JsonToken, mailman, email, out strErrore))
                        {
                            success = false;
                            strError = $"{strErrore} - versione Chilkat={verChilkat}";
                        }
                    }
                }
                else
                {
                    strCause = "Invia l'email. mailman.SendEmail";
                    //'-- invia email
                    success = mailman.SendEmail(email);
                    dt.Write("CTLMailSystem riga 326 - dopo mailman.SendEmail(email) - success=" + success.ToString());
                }

                if (!success)
                {
                    strError = mailman.LastErrorText + " - versione Chilkat=" + verChilkat;
                    dt.Write("CTLMailSystem riga 331 - errore SendEmail: " + strError);
                }

                sqlParams.Clear();
                sqlParams.Add("@DescrError", strError);
                sqlParams.Add("@NumRetry", NumRetry + 1);
                sqlParams.Add("@DocKey", CStr(strDocKey));

                strCause = "Aggiorno la CTL_Mail_System con l'esito dell'invio mail";

                //'-- salva esito nella tabella
                if (!success)
                {
                    statusMail = 1;

                    cdf.ExecuteWithTransaction("update CTL_Mail_System set Status='Error',DescrError=@DescrError,NumRetry=@NumRetry where id=@DocKey", cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);
                }
                else
                {
                    statusMail = 2;

                    cdf.ExecuteWithTransaction("update CTL_Mail_System set Status='Sent',DescrError='',NumRetry=@NumRetry where id=@DocKey", cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);

                    // aggiorna la colonna DataSent (il resume next l'ho messo nel caso in cui la colonna non dovesse esistere su qualche ambiente)
                    try
                    {
                        cdf.ExecuteWithTransaction("update CTL_Mail_System set DataSent = getdate() where id=@DocKey", cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);
                    }
                    catch
                    {
                        dt.Write($"{MODULE_NAME} - aggiorna la colonna DataSent");
                    }
                }

                //-- cancella il file della mail
                CommonStorage.DeleteFile(strFileAttach);

                ret = ELAB_RET_CODE.RET_CODE_OK;
                dt.Write("CTLMailSystem riga 357 - esito finale:" + ret.ToString());
            }
            catch (Exception ex)
            {
                strCause = $"{strCause} DocType:[{strDocType}] -  strDocKey:[{strDocKey}] - lIdPfu:[{lIdPfu}] - strParam:[{strParam}]";
                dt.Write("CTLMailSystem riga 368 - catch:" + ex.ToString());

                if (strAbortOnError != "1")
                    //        AFLErrorControl.StoreErrWithSource MODULE_NAME & " - ERRORE NON BLOCCANTE - " & strCause
                    //    Else
                    //        AFLErrorControl.StoreErrWithSource MODULE_NAME & " - " & strCause
                    //    End If

                    try
                    {
                        // se la mail non è stata inviata e non è in errore incremente il contatore dei tentativi per non bloccare la coda dei messaggi
                        if (statusMail == 0)
                        {
                            NumRetry = NumRetry + 1;

                            var sqlParams = new Dictionary<string, object?>();
                            sqlParams.Add("@NumRetry", NumRetry);
                            sqlParams.Add("@DocKey", CStr(strDocKey));

                            if (NumRetry > mp_NumRetry)
                                cdf.ExecuteWithTransaction("update CTL_Mail_System set  Status='Error',DescrError='Generic Sent Error' where id=@DocKey", cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);
                            else
                                cdf.ExecuteWithTransaction("update CTL_Mail_System set NumRetry = @NumRetry where id = @DocKey", cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);
                        }
                    }
                    catch (Exception ex2)
                    {
                        dt.Write("CTLMailSystem riga 394 - catch vuoto:" + ex2.ToString());

                    }

                if (strAbortOnError != "1")
                    ret = ELAB_RET_CODE.RET_CODE_OK;
                //        AFLErrorControl.DecodeErr False
                //        err.Clear
                //else
                //        AFLErrorControl.DecodeErr True
                //    End If
                //    CloseConnectionIfRequired(cnLocal, connection);
            }

            return ret;
        }

        public void GoToFine(SqlConnection cnLocal, SqlTransaction transaction, int statusMail, int NumRetry, string strDocKey)
        {
            //' se la mail non è stata inviata e non è in errore incremente il contatore dei tentativi per non bloccare la coda dei messaggi
            if (statusMail == 0)
            {

                NumRetry = NumRetry + 1;

                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@NumRetry", NumRetry + 1);
                sqlParams.Add("@DocKey", strDocKey);

                if (NumRetry > mp_NumRetry)
                {
                    //'cnLocal.Execute "update CTL_Mail_System set  Status='error',DescrError='Generic Sent Error'  where id=" & strDocKey
                    cdf.ExecuteWithTransaction("update CTL_Mail_System set  Status='Error',DescrError='Generic Sent Error' where id=@DocKey", cnLocal.ConnectionString, cnLocal, trans, iTimeout, sqlParams);
                }
                else
                {
                    cdf.ExecuteWithTransaction("update CTL_Mail_System set NumRetry=@NumRetry where id=@DocKey", cnLocal.ConnectionString, cnLocal, trans, iTimeout, sqlParams);
                }
            }

            //' -- rilascio memoria
            //CloseRecordset rs
            //Set mp_fs = Nothing
            //Set mailman = Nothing
            //Set email = Nothing
            //Set mp_collParameters = Nothing
            //Set mp_collCNV = Nothing
            //Set mp_collBody = Nothing
            //Set mp_fs = Nothing
            //
            //If Not IsEmpty(vAttachPath) Then
            //    Erase vAttachPath
            //    Erase vAttachName
            //End If
            //
            //CloseRecordset rsDocument
            //CloseRecordset RsDest

            //' Chiusura connessione
            //strCause = "Chiusura connessione al DB"
            //CloseConnection cnLocal
            //'    If Not objctx Is Nothing Then
            //'        objctx.SetComplete
            //'    End If
        }

        private bool GetParameters(string strParam)
        {
            // On Error GoTo err
            bool bReturn = false;

            //' I parametri vengono passati come Field1=Valore1&Field2=Valore2....

            try
            {
                mp_collParameters = GetCollectionExt(strParam);

                //    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                //    ' controlli sui parametri passati
                //    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                if (mp_collParameters.ContainsKey("NumRetry"))
                    mp_NumRetry = CInt(mp_collParameters["NumRetry"]);

                if (mp_NumRetry == 0)
                    mp_NumRetry = 9;

                //' disattiva le transazioni
                strAbortOnError = "0";

                bReturn = true;
            }
            catch (Exception ex)
            {
                dt.Write("CTLMailSystem riga 526 - " + ex.ToString());
                throw new Exception(ex.Message + " - FUNZIONE : " + MODULE_NAME + ".GetParameters", ex);
            }

            bReturn = true;

            return bReturn;
        }

        private string SaveAttachToFile(SqlConnection cnLocal, SqlTransaction? transaction, string keyAttach, string strPath)
        {
            string ret = string.Empty;

            try
            {
                //'{D2E220E2-DA47-4EBA-81CD-899AA11A3017}.eml*EML*822*6330FFB227AA483CB7EAA681ED1800A5

                string strPathFile = "";
                string strGuid = "";

                string[] vv = keyAttach.Split("*");

                strGuid = vv[3];

                //'Set obj = CreateObject("ctldb.Lib_dbAttach")

                //SetRsRead rsAttach, cnLocal

                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@ATT_Hash_Guid", strGuid);
                dt.Write("CTLMailSystem riga 556 -sqlParams: " + strGuid);
                TSRecordSet rsAttach = cdf.GetRSReadFromQueryWithTransaction("select ATT_IdRow from ctl_Attach with (nolock) where ATT_Hash = @ATT_Hash_Guid", cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);
                dt.Write(rsAttach.ToString()!);
                if (!(rsAttach.EOF && rsAttach.BOF))
                {
                    rsAttach.MoveFirst();

                    strPathFile = strPath + vv[0];

                    dt.Write("CTLMailSystem riga 565 - prima di saveFileFromRecordSet");

                    CommonDB.Basic.saveFileFromRecordSet("ATT_Obj", "ctl_Attach", "ATT_IdRow", CInt(rsAttach["ATT_IdRow"]!), strPathFile, cnLocal, transaction);

                    ret = strPathFile;
                    dt.Write($"CTLMailSystem riga 570 - dopo saveFileFromRecordSet - pathFile = {strPathFile}");
                }
            }
            catch (Exception ex)
            {
                dt.Write("CTLMailSystem riga 575 - SaveAttachToFile: " + ex.ToString());
                throw new Exception($"{ex.Message} - FUNZIONE : {MODULE_NAME}.SaveAttachToFile", ex);
            }

            return ret;
        }

        private void GetMailParam(SqlConnection cnLocal, SqlTransaction? transaction, string strMailFrom, Chilkat.MailMan mailman)
        {
            bool bCounter = false;
            int lID = 0;
            string strCause = "";
            string strSQL = "";
            TSRecordSet rsMail = new TSRecordSet();
            Email.Cr obj;
            string strPwd = "";

            obj = new Email.Cr();

            bCounter = false;

            //'--recupero parametri per invio mail
            strCause = $"recupero parametri invio mail per alias={strMailFrom}";

            var sqlParams = new Dictionary<string, object?>();
            sqlParams.Add("@MailFrom", Trim(strMailFrom));

            strSQL = " select top 1 *, dbo.DecryptPwd(password) as pwdDecrypt from CTL_CONFIG_MAIL  with (nolock) where alias=@MailFrom order by counter asc";

            try
            {
                rsMail = cdf.GetRSReadFromQueryWithTransaction(strSQL, cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);
                bCounter = true;
            }
            catch
            {
                dt.Write($"{MODULE_NAME} - {strCause}");
            }

            if (!bCounter)
            {
                sqlParams.Clear();
                sqlParams.Add("@MailFrom", Trim(strMailFrom));

                strSQL = " select top 1 *, dbo.DecryptPwd(password) as pwdDecrypt from CTL_CONFIG_MAIL  with (nolock) where alias=@MailFrom";
                rsMail = cdf.GetRSReadFromQueryWithTransaction(strSQL, cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);
            }

            if (!(rsMail.EOF && rsMail.BOF))
            {
                rsMail.MoveFirst();

                while (!rsMail.EOF)
                {

                    lID = CInt(rsMail["id"]!);

                    strPwd = CStr(rsMail["pwdDecrypt"]);

                    //' Set the POP3 server's hostname
                    mailman.SmtpHost = CStr(rsMail["Server"]);

                    if (!string.IsNullOrEmpty(CStr(rsMail["UserName"])))
                    {
                        mailman.SmtpUsername = CStr(rsMail["UserName"]);
                        mailman.SmtpPassword = strPwd;
                    }

                    if (CInt(rsMail["ServerPort"]!) > 0)
                    {
                        mailman.SmtpPort = CInt(rsMail["ServerPort"]!);
                    }

                    if (CInt(rsMail["UseSSL"]!) > 0)
                    {
                        mailman.SmtpSsl = CBool(CInt(rsMail["UseSSL"]!));
                    }

                    //Authenticate può assumere valoti 0 e 1, nal caso di 1 corrisponde a LOGIN, 0 a NONE
                    if (CInt(rsMail["Authenticate"]!) == 1)
                        mailman.SmtpAuthMethod = "LOGIN";
                    else
                        mailman.SmtpAuthMethod = "NONE";

                    if (cdf.FieldExistsInRS(rsMail, "StartTLS") && rsMail["StartTLS"] is not null)
                    {
                        //'-- questo campo dovrebbe essere sempre a 1 quando UseSSL è a 1
                        //'-- ma la sua assenza non causa problemi sulla maggioranza
                        //'-- dei server. in caso di errore metterlo a 1. lasciarlo a null
                        //'-- se UseSSL è  0
                        //'-- valori ammessi : 0 o 1
                        //'-- se la colonna è null non setto niente sul campo in mailMan
                        mailman.StartTLS = CBool(CInt(rsMail["StartTLS"]!));
                    }

                    // nuovi campi per XOAUTH2 office 365
                    if (cdf.FieldExistsInRS(rsMail, "LoginMethod") && rsMail["LoginMethod"] is not null)
                    {
                        m_LoginMethod = Trim(CStr(rsMail["LoginMethod"])).ToUpper();
                    }

                    if (cdf.FieldExistsInRS(rsMail, "JsonToken") && rsMail["JsonToken"] is not null)
                    {
                        m_JsonToken = Trim(CStr(rsMail["JsonToken"]));
                    }

                    if (cdf.FieldExistsInRS(rsMail, "FrequencyUpdateToken") && rsMail["FrequencyUpdateToken"] is not null)
                    {
                        m_FrequencyUpdateToken = (CInt(rsMail["FrequencyUpdateToken"]!));
                    }

                    if (cdf.FieldExistsInRS(rsMail, "ClientId") && rsMail["ClientId"] is not null)
                    {
                        m_ClientId = Trim(CStr(rsMail["ClientId"]));
                    }

                    if (cdf.FieldExistsInRS(rsMail, "ClientSecret") && rsMail["ClientSecret"] is not null)
                    {
                        m_ClientSecret = Trim(CStr(rsMail["ClientSecret"]));
                    }

                    if (cdf.FieldExistsInRS(rsMail, "TokenEndpoint") && rsMail["TokenEndpoint"] is not null)
                    {
                        m_TokenEndpoint = Trim(CStr(rsMail["TokenEndpoint"]));
                    }

                    if (cdf.FieldExistsInRS(rsMail, "DateUpdateToken") && rsMail["DateUpdateToken"] is not null)
                    {
                        m_DateUpdateToken = Convert.ToDateTime(rsMail["DateUpdateToken"]);
                    }

                    //''-- incrementa il counter
                    if (bCounter)
                    {
                        sqlParams.Clear();
                        sqlParams.Add("@ID", lID);

                        cdf.ExecuteWithTransaction("update CTL_CONFIG_MAIL set counter = counter + 1 where id=@ID", cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);
                    }

                    rsMail.MoveNext();
                }
            }
        }

        private string? GetParamValue(string strKey)
        {
            if (mp_collParameters.ContainsKey(strKey))
            {
                return mp_collParameters[strKey];
            }
            return null;
        }
    }
}
