using eProcurementNext.Application;
using eProcurementNext.BizDB;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.Core.Storage;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using static eProcurementNext.CommonDB.Basic;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;
using static eProcurementNext.CtlProcess.Basic;

namespace eProcurementNext.CtlProcess
{
    internal class ClsSendMail : ProcessBase
    {
        private readonly CommonDbFunctions cdf = new();
        private const string MODULE_NAME = "CtlProcess.ClsSendMail";
        private Dictionary<string, string>? mp_collParameters = null!;
        private Dictionary<string, string> mp_collCNV = new Dictionary<string, string>();
        private Dictionary<string, string> mp_collBody = new Dictionary<string, string>();
        string mp_strTypeDoc = string.Empty;
        string mp_strKeyDoc = string.Empty;
        string strAbortOnError = string.Empty;

        const string MAIL_FILE_NAME = "MAIL_FILE_NAME";
        const string OBJECT_MAIL = "OBJECT_MAIL";
        const string QUERY_GETUSERS_DEST = "QUERY_GETUSERS_DEST";
        const string MAIL_FROM = "MAIL_FROM";
        const string ABORT_ON_ERROR = "ABORT_ON_ERROR";
        const string USE_MITT = "USE_MITT";
        const string view = "VIEW";
        const string MAIL_KEY_ML = "MAIL_KEY_ML";

        long mp_Idpfu = 0;

        const string QUERY_ATTACH = "QUERY_ATTACH";
        const string URL_FILE = "URL_FILE";
        const string BODY_URL_FILE = "BODY_URL_FILE";

        private IList<string> vAttachPath = null!;
        private IList<string> vAttachName = null!;

        const string URL_FILE_EXT = "URL_FILE_EXT";
        const string URL_FILE_NAME = "URL_FILE_NAME";

        private int iTimeout = -1;

        private readonly DebugTrace dt = new();

        public override ELAB_RET_CODE Elaborate(string strDocType, dynamic strDocKey, long lIdPfu, string strParam, ref string strDescrRetCode, dynamic? vIdMp = null, dynamic? connection = null, SqlTransaction? transaction = null, int timeout = -1)
        {
            ELAB_RET_CODE ret = ELAB_RET_CODE.RET_CODE_ERROR;

            string strCause = string.Empty;
            SqlConnection? cnLocal = null!;
            iTimeout = timeout;

            try
            {
                TSRecordSet? RsDest = null;

                ret = ELAB_RET_CODE.RET_CODE_ERROR;
                strDescrRetCode = "";
                mp_Idpfu = lIdPfu;

                mp_strTypeDoc = strDocType;
                mp_strKeyDoc = CStr(strDocKey);

                if (vIdMp == null)
                {
                    strDescrRetCode = "Parametro MarketPlace non valorizzato";
                    dt.Write("clsSendMail - Parametro MarketPlace non valorizzato");
                    return ret;
                }

                //' Apertura connessione
                strCause = "Apertura connessione al DB";
                if (connection is null)
                {
                    connection = ApplicationCommon.Application.ConnectionString;
                    cnLocal = cdf.SetConnection(connection);
                }
                else if (connection is SqlConnection)
                {
                    cnLocal = connection;
                }
                else
                {
                    cnLocal = cdf.SetConnection(connection);
                }

                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                //' STEP 1 --- legge i parametri necessari
                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                strCause = "Lettura dei parametri che determinano le azioni";
                bool bOK = false;
                bOK = GetParameters(strParam, ref strDescrRetCode, cnLocal, transaction);
                dt.Write("clsSendMail riga 146 dopo GetParameters");
                if (!bOK)
                {
                    dt.Write("clsSendMail riga 149 |!bOK|");
                    return ret;
                }

                strCause = "Lettura parametro TIMEOUT";
                string tmpTimeout = GetParamValue("TIMEOUT");
                if (!string.IsNullOrEmpty(tmpTimeout))
                {
                    iTimeout = CInt(tmpTimeout);
                }

                //'' -- 18/01/2019 reso sempre bloccante l'invio della mail
                strAbortOnError = "1";

                //'-- se c'è il parametro di ignorare l'errore ma c'è anche la SYS di non mandare le mail tramite questa classe allora rimette il parametro a 1
                if (strAbortOnError != "1")
                {
                    string sValore = string.Empty;

                    sValore = BizDB.Basic.GetValueSys(cnLocal, "SYS_ATTIVA_MAIL_BLOCCANTE", transaction);

                    if (sValore.ToUpper() == "NO")
                    {
                        strAbortOnError = "";
                    }
                    else
                    {
                        strAbortOnError = "1";
                    }
                }
                dt.Write("clsSendMail riga 180");

                //    
                //    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                //    ' STEP 5 --- apre il recordset con i destinatari della mail
                //    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                strCause = $"apre il recordset con i destinatari della mail per il documento di tipo={strDocType} e chiave={CStr(strDocKey)}";

                string strDest = string.Empty;

                if (mp_collParameters is not null)
                {
                    strDest = mp_collParameters[QUERY_GETUSERS_DEST];
                }

                strDest = strDest.Replace("<ID_DOC>", CStr(strDocKey));
                strDest = strDest.Replace("<ID_USER>", CStr(lIdPfu));

                dt.Write("clsSendMail riga 244");

                if (vIdMp != null)
                {
                    strDest = strDest.Replace("<ID_MP>", CStr(vIdMp));
                }

                var dbProfiler = new DbProfiler(ApplicationCommon.Configuration);
                dbProfiler.startProfiler();

                RsDest = cdf.GetRSReadFromQueryWithTransaction($"{GetSQLPrefixStatement()}{strDest}", cnLocal.ConnectionString, cnLocal, transaction, iTimeout);

                dbProfiler.endProfiler();
                dbProfiler.traceDbProfiler(strDest, ApplicationCommon.Application.ConnectionString); // cnLocal.ConnectionString);

                dt.Write("clsSendMail riga 259");

                //' nessun destinatario trovato esce
                if (RsDest.EOF && RsDest.BOF)
                {
                    ret = ELAB_RET_CODE.RET_CODE_OK;
                    return ret;
                }

                RsDest.MoveFirst();

                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                //' STEP 6 --- Invia la mail ai destinatari
                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                dt.Write("clsSendMail riga 273 - prima di SendMailUsers");
                strCause = "Invia la mail ai destinatari";
                SendMailUsers(cnLocal, transaction, RsDest, strDocType, strDocKey, lIdPfu);
                dt.Write("clsSendMail riga 276 - dopo SendMailUsers");

                ret = ELAB_RET_CODE.RET_CODE_OK;
            }
            catch (Exception ex)
            {
                strCause = $"{strCause} DocType:[{strDocType}] -  strDocKey:[{strDocKey}] - lIdPfu:[{lIdPfu}] - strParam:[{strParam}]";

                string strNewError = string.Empty;

                if (strAbortOnError != "1")
                {
                    strNewError = $"{MODULE_NAME} - ERRORE NON BLOCCANTE - {strCause}";
                    ret = ELAB_RET_CODE.RET_CODE_OK;
                    CommonDB.Basic.TraceErr(ex, cnLocal.ConnectionString, strNewError);
                }
                else
                {
                    strNewError = $"{MODULE_NAME} - {strCause}";
                    CommonDB.Basic.TraceErr(ex, cnLocal.ConnectionString, strNewError);
                    throw new Exception(strNewError, ex);
                }
            }

            return ret;
        }

        private bool GetParameters(string strParam, ref string strDescrRetCode, SqlConnection cnLocal, SqlTransaction? transaction)
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
                if (!mp_collParameters.ContainsKey(MAIL_FILE_NAME))
                {
                    strDescrRetCode = $"Manca il parametro input {MAIL_FILE_NAME}";
                    return bReturn;
                }

                if (!mp_collParameters.ContainsKey(OBJECT_MAIL))
                {
                    strDescrRetCode = $"Manca il parametro input {OBJECT_MAIL}";
                    return bReturn;
                }

                if (!mp_collParameters.ContainsKey(QUERY_GETUSERS_DEST))
                {
                    strDescrRetCode = $"Manca il parametro input {QUERY_GETUSERS_DEST}";
                    return bReturn;
                }

                // MAIL_FROM
                // 1. Prende il valore dalla configurazione
                // 2. Lo cerca nella lib_multilinguismo
                // 3. Lo prende dal registro

                string strvalue = string.Empty;
                if (mp_collParameters.ContainsKey(MAIL_FROM))
                {
                    strvalue = mp_collParameters[MAIL_FROM];
                }
                try
                {
                    if (string.IsNullOrEmpty(strvalue))
                    {
                        //'--chiamata a CNV_ESTESA per risolvere ML. o SYS.
                        TSRecordSet? rs = cdf.GetRSReadFromQueryWithTransaction("select dbo.CNV_ESTESA( ML_Description ,'I') as ML_Description from lib_multilinguismo with(nolock) where ML_KEY = 'MAIL_FROM_ML'", cnLocal.ConnectionString, cnLocal, transaction, iTimeout);

                        if (rs is not null && rs.RecordCount > 0)
                        {
                            rs.MoveFirst();
                            strvalue = CStr(rs["ML_Description"]);
                        }
                        else
                        {
                            throw new Exception($"Manca il parametro MAIL_FROM_ML. Recupero 'Mail from' non possibile. - FUNZIONE : {MODULE_NAME}.GetParameters");
                        }

                        mp_collParameters.Add(MAIL_FROM, strvalue);
                    }
                    else
                    {
                        //'--chiamata a CNV_ESTESA per risolvere ML. o SYS.
                        var sqlParams = new Dictionary<string, object?>();
                        sqlParams.Add("@strvalue", strvalue);
                        TSRecordSet? rs = cdf.GetRSReadFromQueryWithTransaction("select  dbo.CNV_ESTESA(@strvalue,'I') as ML_Description", cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);

                        if (rs is not null && rs.RecordCount > 0)
                        {
                            rs.MoveFirst();
                            strvalue = CStr(rs["ML_Description"]);
                        }

                        mp_collParameters.Remove(MAIL_FROM);
                        mp_collParameters.Add(MAIL_FROM, strvalue);
                    }
                }
                catch { }

                //' ABORT_ON_ERROR
                if (!mp_collParameters.ContainsKey(ABORT_ON_ERROR))
                {
                    mp_collParameters.Add(ABORT_ON_ERROR, "0");
                    strAbortOnError = mp_collParameters[ABORT_ON_ERROR];
                }

                bReturn = true;
            }
            catch (Exception ex)
            {
                throw new Exception($"{ex.Message} - FUNZIONE : {MODULE_NAME}.GetParameters", ex);
            }

            bReturn = true;

            return bReturn;
        }


        private void SendMailUsers(SqlConnection cnLocal, SqlTransaction transaction, TSRecordSet RsDest, string strDocType, dynamic strDocKey, long lIdPfuMitt)
        {
            string strCause = string.Empty;
            string strPath = string.Empty;
            TSRecordSet? objDoc = null;
            string LastLanguage = string.Empty;
            TSRecordSet? objAttachDoc;
            string idPfu = string.Empty;
            Mail? objMail = null;
            DbProfiler? dbProfiler = null;
            string viewtemp = string.Empty;
            long lIdPfuDest = 0;

            //On Error Resume Next
            if (mp_collParameters!.ContainsKey(USE_MITT))
            {
                idPfu = mp_collParameters[USE_MITT];
            }
            if (!string.IsNullOrEmpty(idPfu))
            {
                idPfu = CStr(mp_Idpfu);
            }

            string strQueryAttach = string.Empty;
            if (mp_collParameters.ContainsKey(QUERY_ATTACH))
            {
                strQueryAttach = mp_collParameters[QUERY_ATTACH];
            }

            try
            {
                string sDirSeparator = CStr(Path.DirectorySeparatorChar);
                dt.Write("clsSendMail riga 510 - SYS_PathFolderPortaleGareTelematiche = " + BizDB.Basic.GetValueSys(cnLocal, "SYS_PathFolderPortaleGareTelematiche", transaction));
                strPath = BizDB.Basic.GetValueSys(cnLocal, "SYS_PathFolderPortaleGareTelematiche", transaction) + $"{sDirSeparator}Web{sDirSeparator}EProcNext{sDirSeparator}wwwroot{sDirSeparator}mail";

                string strEMail = string.Empty;
                string strLanguage = string.Empty;
                dynamic vtBody;
                string vtObject = string.Empty;

                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                //' 12/04/2019 meccanismo di accodamento al body dell'identificativo del template
                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                string strIdTemplate = string.Empty;
                string strLabelTemplate = string.Empty;

                //' vede se attivare il meccanismo di accodamento con l'identificativo del template
                strLabelTemplate = Email.Basic.GetCTLParam(cnLocal, transaction, "MAIL", "ATTIVA_KEY", "DefaultValue");

                if (!string.IsNullOrEmpty(strLabelTemplate) && CStr(GetCollectionValue(mp_collParameters, BODY_URL_FILE)).ToLower() != "yes" && !string.IsNullOrEmpty(GetCollectionValue(mp_collParameters, MAIL_KEY_ML)))
                {
                    strIdTemplate = CStr(GetIdTemplate(cnLocal, transaction, GetCollectionValue(mp_collParameters, MAIL_KEY_ML)));
                    strLabelTemplate = Replace(strLabelTemplate, "#id#", strIdTemplate, 1, -1, Microsoft.VisualBasic.CompareMethod.Text);
                }

                strCause = "CreateObject di ctldb.Lib_dbMultiLanguage";
                dt.Write("clsSendMail - SendMailUsers - INIZIO");
                if (RsDest.RecordCount > 0 && !string.IsNullOrEmpty(strQueryAttach))
                {
                    //'-- se ci sono destinatari recupero gli allegati se configurati
                    //'--se configurato recupero gli attach del documento
                    strQueryAttach = strQueryAttach.Replace("<ID_DOC>", mp_strKeyDoc);
                    strQueryAttach = strQueryAttach.Replace("<ID_USER>", idPfu);

                    dbProfiler = new DbProfiler(ApplicationCommon.Configuration);
                    dbProfiler.startProfiler();

                    strCause = $"recupero allegati dalla query {strQueryAttach}";
                    objAttachDoc = cdf.GetRSReadFromQueryWithTransaction(strQueryAttach, cnLocal.ConnectionString, cnLocal, transaction, iTimeout);

                    dbProfiler.endProfiler();
                    dbProfiler.traceDbProfiler(strQueryAttach, ApplicationCommon.Application.ConnectionString); // cnLocal.ConnectionString);
                    //Set dbProfiler = Nothing

                    if (objAttachDoc is not null && objAttachDoc.RecordCount > 0)
                    {
                        objAttachDoc.MoveFirst();
                        while (!objAttachDoc.EOF)
                        {
                            //'--recupero allegato dal blob
                            strCause = $"recupero allegato dal blob={CStr(objAttachDoc["attach"])}";
                            GetAllegato(CStr(objAttachDoc["attach"]), cnLocal, transaction, false);

                            objAttachDoc.MoveNext();
                        }
                    }
                }

                string sFileTemplate = string.Empty;
                string myURL = CStr(GetCollectionValue(mp_collParameters, URL_FILE));

                bool bUtenteAttivo = false;

                //' per ogni destinatario
                RsDest.MoveFirst();

                while (!RsDest.EOF)
                {
                    //'''' 19 / 8 / 2019 controllo presenza NULL nell'indirizzo mail
                    if (RsDest["pfue_Mail"] is null)
                    {
                        strEMail = "";
                    }
                    else
                    {
                        strEMail = Trim(CStr(RsDest["pfue_Mail"]));
                    }
                    strLanguage = Trim(CStr(RsDest["lngsuffisso"]));

                    if (cdf.FieldExistsInRS(RsDest, "IdPfu"))
                    {
                        lIdPfuDest = CLng(RsDest["IdPfu"]!);
                    }
                    else
                    {
                        lIdPfuDest = -1;
                    }

                    bUtenteAttivo = true;

                    if (lIdPfuDest > 0)
                    {
                        bUtenteAttivo = IsUtenteAttivo(lIdPfuDest, cnLocal, transaction);
                    }

                    LastLanguage = strLanguage;
                    dt.Write("clsSendMail - SendMailUsers - PARAMETRI");
                    if (objDoc is null)
                    {
                        string TABLE = string.Empty;
                        TABLE = $"MAIL_{mp_strTypeDoc}";

                        //'Se c'è il parametro VIEW usiamo quello come table per il from altrimento lasciamo la vecchia convenzione
                        //'di fare MAIL_nomeDocumento
                        viewtemp = CStr(GetCollectionValue(mp_collParameters, view));
                        if (!string.IsNullOrEmpty(viewtemp))
                        {
                            TABLE = viewtemp;
                        }

                        dbProfiler = new DbProfiler(ApplicationCommon.Configuration);
                        dbProfiler.startProfiler();

                        var sqlParams = new Dictionary<string, object?>();
                        sqlParams.Add("@LastLanguage", LastLanguage);
                        sqlParams.Add("@KeyDoc", CInt(mp_strKeyDoc));
                        sqlParams.Add("@idPfu", CInt(idPfu));
                        string strTmpSql = $"select * from {TABLE} where LNG = @LastLanguage and idDoc = @KeyDoc";
                        if (!string.IsNullOrEmpty(idPfu))
                        {
                            strTmpSql = $"{strTmpSql} and IdPfuMittDoc = @idPfu";
                        }

                        strCause = $"Recupero il documento dal DB con QUERY={strTmpSql}";

                        objDoc = cdf.GetRSReadFromQueryWithTransaction(strTmpSql, cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);

                        dbProfiler.endProfiler();
                        dbProfiler.traceDbProfiler(strTmpSql, ApplicationCommon.Application.ConnectionString); // cnLocal.ConnectionString);

                        if (objDoc is not null && objDoc.RecordCount > 0)
                        {
                            objDoc.MoveFirst();
                        }

                        myURL = CStr(GetCollectionValue(mp_collParameters, URL_FILE));

                        if (!string.IsNullOrEmpty(myURL))
                        {

                            //'-- cancello il file precedente
                            myURL = myURL.Replace("<ID_DOC>", mp_strKeyDoc);
                            myURL = myURL.Replace("<TYPE_DOC>", mp_strTypeDoc);
                            myURL = myURL.Replace("<LNG_DOC>", strLanguage);

                            string SYS_WEBSERVERAPPLICAZIONE = string.Empty;

                            SYS_WEBSERVERAPPLICAZIONE = GetSys(cnLocal, "SYS_WEBSERVERAPPLICAZIONE", transaction);

                            if (!string.IsNullOrWhiteSpace(SYS_WEBSERVERAPPLICAZIONE))
                            {
                                myURL = myURL.Replace("<SYS_WEBSERVERAPPLICAZIONE>", SYS_WEBSERVERAPPLICAZIONE);
                            }

                            if (!string.IsNullOrEmpty(sFileTemplate) && File.Exists(sFileTemplate))
                            {
                                File.Delete(sFileTemplate);
                            }

                            strCause = $"recupero html per url={myURL}";
                            string html = string.Empty;
                            if (mp_collParameters.ContainsKey(URL_FILE_EXT))
                            {
                                html = GetHtml(myURL, true, ref sFileTemplate, mp_collParameters[URL_FILE_EXT], connectionString: cnLocal.ConnectionString);
                            }
                            else
                            {
                                html = GetHtml(myURL, true, ref sFileTemplate, ".html", connectionString: cnLocal.ConnectionString);
                            }
                            if (mp_collParameters.ContainsKey(URL_FILE_NAME))
                            {
                                AddAttach(sFileTemplate, mp_collParameters[URL_FILE_NAME]);
                            }
                            else
                            {
                                AddAttach(sFileTemplate, "Document");
                            }
                        }
                    }

                    //'''' 9 / 7 / 2019 controllo validità indirizzo mail
                    strEMail = GetMaiAddressOK(strEMail);

                    dt.Write("clsSendMail - SendMailUsers - Prima di GetObjectMail");

                    //''' invia la mail solo agli utenti attivi
                    if (!string.IsNullOrWhiteSpace(strEMail) && bUtenteAttivo)
                    {
                        strCause = "Traduce l'oggetto della mail";
                        //'vtObject = CNV _SQL(mp_collParameters(OBJECT_MAIL), pOBJSESSION) 'GetObjectMail(mp_collParameters(OBJECT_MAIL), strLanguage, objCNV)
                        //'-- recupera dal ML la descrizione
                        vtObject = GetObjectMail(mp_collParameters[OBJECT_MAIL], strLanguage, cnLocal, transaction, objDoc);

                        dt.Write("clsSendMail - SendMailUsers - Prima di SetAttribValues");
                        //' rimpiazza eventuali valori di attributi
                        vtObject = SetAttribValues(vtObject, objDoc, strLanguage, cnLocal, transaction);
						vtObject = Replace(vtObject, "~~@@@~~", "#");
                        vtObject = HtmlDecode(vtObject);

						strCause = "Determina il body della mail";

                        if (CStr(GetCollectionValue(mp_collParameters, BODY_URL_FILE)).ToLower() == "yes")
                        {
                            vtBody = GetBodyMailFromFile(sFileTemplate, cnLocal.ConnectionString);
                        }
                        else
                        {
                            vtBody = GetBodyMail(strLanguage, objDoc, strPath, cnLocal, transaction, strLabelTemplate);
                        }
						vtBody = Replace(vtBody, "~~@@@~~", "#");
						dt.Write("clsSendMail - SendMailUsers - Dopo GetBodyMail");

                        if (!string.IsNullOrWhiteSpace(vtBody))
                        {
                            strCause = $"Invia la mail all'utente {strEMail}";
                            objMail = new Mail();

                            //'-- Se è presente la colonna MAIL_FROM_CONFIG nel recordset dei destinatari
                            //'-- uso il suo valore come mittente della mail, altrimenti lascio strEMail

                            string strTempMittente = string.Empty;
                            strTempMittente = mp_collParameters[MAIL_FROM];

                            //'-- se è presente la colonna e il suo valore non è null
                            if (cdf.FieldExistsInRS(RsDest, "MAIL_FROM_CONFIG") && RsDest["MAIL_FROM_CONFIG"] is not null)
                            {
                                strTempMittente = CStr(RsDest["MAIL_FROM_CONFIG"]);
                            }

                            //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                            //''-- gestione delle colonna CC e CCn
                            //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                            string strMailCC = string.Empty;
                            string strMailCCN = string.Empty;

                            if (cdf.FieldExistsInRS(RsDest, "MAIL_CC") && RsDest["MAIL_CC"] is not null)
                            {
                                strMailCC = CStr(RsDest["MAIL_CC"]);
                            }

                            if (cdf.FieldExistsInRS(RsDest, "MAIL_CCN") && RsDest["MAIL_CCN"] is not null)
                            {
                                strMailCC = CStr(RsDest["MAIL_CCN"]);
                            }
                            dt.Write("clsSendMail - SendMailUsers - prima di par idAziDest");
                            dynamic? idAziDest = null;

                            if (cdf.FieldExistsInRS(RsDest, "idAziDest") && RsDest["idAziDest"] is not null)
                            {
                                idAziDest = RsDest["idAziDest"];
                            }
                            dt.Write("clsSendMail - SendMailUsers - dopo par idAziDest");
                            if (!string.IsNullOrEmpty(strLabelTemplate))
                            {
                                vtBody = $"{vtBody}{strLabelTemplate}";
                            }
                            dt.Write("clsSendMail - SendMailUsers - Prima di SendWithCDOSYS_New");
                            objMail.SendWithCDOSYS_New(strEMail, strTempMittente, strMailCC, strMailCCN, vtObject, vtBody, vAttachPath, vAttachName, strLanguage, MAIL_BODY_FORMAT.HTML, ref cnLocal, ref transaction, strDocType, strDocKey, lIdPfuMitt, lIdPfuDest, idAziDest);
                        }
                    }

                    RsDest.MoveNext();
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"{strCause} - {ex.Message} - FUNZIONE : {MODULE_NAME}.SendMailUsers", ex);
            }
            finally
            {
                //'--cancello gli eventuali allegati che abbiamo aggiunto al
                int i = 0;
                if (vAttachPath is not null)
                {
                    foreach (var attach in vAttachPath)
                    {
                        strCause = $"cancello il file={vAttachPath[i]}";
                        if (CommonStorage.ExistsFile(vAttachPath[i]))
                        {
                            CommonStorage.DeleteFile(vAttachPath[i]);
                        }
                    }
                }
            }
        }

        private dynamic GetObjectMail(string strKeyMlng, string strLanguage, SqlConnection cnLocal, SqlTransaction transaction, TSRecordSet objDocument)
        {
            string ret = string.Empty;
            string s = string.Empty;

            try
            {
                mp_collCNV = new Dictionary<string, string>();

                //' cerca se trova una key specializzata per oggetto mail
                if (!string.IsNullOrEmpty(strKeyMlng))
                {
                    TSRecordSet? rs;
                    TSRecordSet? rs2;

                    s = string.Empty;

                    var sqlParams = new Dictionary<string, object?>();
                    try
                    {
                        sqlParams.Add("@Language", strLanguage);
                        sqlParams.Add("@KeyMlng_TipoDoc", $"{strKeyMlng}_{CStr(objDocument["TipoDocumento"])}");
                        rs2 = cdf.GetRSReadFromQueryWithTransaction("select dbo.CNV_ESTESA(ML_Description, @Language) as ML_Description from LIB_Multilinguismo with(nolock) where ML_KEY = @KeyMlng_TipoDoc and ML_LNG = @Language", cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);

                        if (rs2 is not null && rs2.RecordCount > 0)
                        {
                            rs2.MoveFirst();
                            s = CStr(rs2["ML_Description"]);
                            s = SetAttribValues(s, objDocument, strLanguage, cnLocal, transaction);
                        }
                    }
                    catch { }

                    // 'comportamento antecedente la specializzazione
                    if (string.IsNullOrEmpty(s))
                    {
                        //' cerca prima nella collezione per vedere se ha già tradotto la stringa

                        if (mp_collCNV.ContainsKey($"{strKeyMlng}_{strLanguage}"))
                        {
                            ret = mp_collCNV[$"{strKeyMlng}_{strLanguage}"];
                            return ret;
                        }

                        //--chiamata  CNV_ESTESA per risolvere ML. o SYS.
                        sqlParams.Clear();
                        sqlParams.Add("@Language", strLanguage);
                        sqlParams.Add("@KeyMlng", strKeyMlng);
                        rs = cdf.GetRSReadFromQueryWithTransaction("select dbo.CNV_ESTESA(ML_Description ,@Language) as ML_Description from LIB_Multilinguismo with(nolock) where ML_KEY = @KeyMlng and ML_LNG = @Language", cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);

                        if (rs is not null && rs.RecordCount > 0)
                        {
                            rs.MoveFirst();
                            s = CStr(rs["ML_Description"]);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"{ex.Message} - FUNZIONE : {MODULE_NAME}.GetObjectMail", ex);
            }

            return s;
        }


        private dynamic GetBodyMail(string strLanguage, TSRecordSet objDocument, string strPath, SqlConnection cnLocal, SqlTransaction transaction, string strLabelTemplate)
        {
            string ret = string.Empty;
            string? s = string.Empty;
            dt.Write("clsSendMail - GetBodyMail - INIZIO");

            if (mp_collBody is null)
            {
                mp_collBody = new Dictionary<string, string>();
            }

            //' cerca prima nella collezione per vedere se ha già tradotto la stringa
            if (mp_collBody.ContainsKey(strLanguage))
            {
                s = mp_collBody[strLanguage];
                return s;
            }

            if (!string.IsNullOrEmpty(GetCollectionValue(mp_collParameters, MAIL_KEY_ML)))
            {
                s = string.Empty;
                string strSql = string.Empty;

                if (cdf.FieldExistsInRS(objDocument, "TipoDocumento"))
                {
                    var sqlParams = new Dictionary<string, object?>();
                    sqlParams.Add("@ML_KEY", $"{CStr(mp_collParameters[MAIL_KEY_ML])}_{CStr(objDocument["TipoDocumento"])}");
                    sqlParams.Add("@Language", strLanguage);
                    strSql = "select ML_Description from LIB_Multilinguismo with(nolock) where ML_KEY = @ML_KEY and ML_LNG = @Language";
                    TSRecordSet? rs2 = cdf.GetRSReadFromQueryWithTransaction(strSql, cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);

                    if (rs2 is not null && rs2.RecordCount > 0)
                    {
                        rs2.MoveFirst();
                        s = CStr(rs2["ML_Description"]);
                        s = SetAttribValues(s, objDocument, strLanguage, cnLocal, transaction);

                        //' se ha trovato il template specifico per documento deve modificare la label con l'id template da mettere in coda alla mail
                        if (!string.IsNullOrEmpty(strLabelTemplate))
                        {
                            string strIdTemplate = CStr(GetIdTemplate(cnLocal, transaction, $"{GetCollectionValue(mp_collParameters, MAIL_KEY_ML)}_{CStr(objDocument["TipoDocumento"])}"));

                            if (!string.IsNullOrEmpty(strIdTemplate))
                            {
                                // rilegge la chiave dai parametri avendo già fatto la replace
                                strLabelTemplate = Email.Basic.GetCTLParam(cnLocal, transaction, "MAIL", "ATTIVA_KEY", "DefaultValue");
                                strLabelTemplate = Replace(strLabelTemplate, "#id#", strIdTemplate, 1, -1, Microsoft.VisualBasic.CompareMethod.Text);
                            }
                        }
                    }
                }

                if (string.IsNullOrEmpty(s))
                {
                    var sqlParams = new Dictionary<string, object?>
                    {
                        { "@ML_KEY", mp_collParameters[MAIL_KEY_ML] },
                        { "@Language", strLanguage }
                    };

                    strSql = "select ML_Description from LIB_Multilinguismo with(nolock) where ML_KEY = @ML_KEY and ML_LNG = @Language";
                    TSRecordSet? rs = cdf.GetRSReadFromQueryWithTransaction(strSql, cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);

                    if (rs is not null && !(rs.EOF && rs.BOF))
                    {
                        rs.MoveFirst();

                        s = CStr(rs["ML_Description"]);

                        s = SetAttribValues(s, objDocument, strLanguage, cnLocal, transaction);
                    }
                    else
                    {
                        ret = "ERRORE DI CONFIGURAZIONE - Template nella LIB_Multilinguismo non trovato";

                        LogEvent(TsEventLogEntryType.Warning, ret, cnLocal!.ConnectionString, "CtlProcess.clsSendMail");

                        return ret;
                    }
                }
            }
            else
            {
                //' determina il body della mail
                //' legge il file HTML
                string strFileName = Path.Combine(strPath, "\\", Replace(mp_collParameters[MAIL_FILE_NAME], ".html", "_" + strLanguage + ".html", 1, -1, Microsoft.VisualBasic.CompareMethod.Text));

                if (CommonStorage.FileExists(strFileName))
                {
                    s = File.ReadAllText(strFileName);

                    //' rimpiazza eventuali valori di attributi
                    s = SetAttribValues(s, objDocument, strLanguage, cnLocal, transaction);
                }
                else
                {
                    LogEvent(TsEventLogEntryType.Warning, $"ERRORE NON BLOCCANTE -- Non trovato file {strFileName} per costruire il body della mail - TipoDoc={mp_strTypeDoc} - ID={mp_strKeyDoc}", cnLocal!.ConnectionString, "CtlProcess.clsSendMail");
                }
            }

            mp_collBody.Add(strLanguage, s);

            dt.Write("clsSendMail - GetBodyMail - FINE, ret = " + s);

            ret = s;

            return ret;
        }



        private string SetAttribValues(string strExpression, TSRecordSet objDocument, string strLanguage, SqlConnection cnLocal, SqlTransaction transaction)
        {
            //' -- STEP 1 : estrae tutte le stringhe da valutare del tipo
            //' #Identifier.FieldName# dove
            //' Identifier = Document, Company_Fix, Company_Opt, User_Fix, User_Opt,  TabApproval

            int l = 0;
            int i = 0;
            int j = 0;
            string[] ss;
            Dictionary<string, string> Coll = new();
            dynamic Valore;

            l = strExpression.Length;
            bool b = false;
            j = 0;

            for (i = 0; i < l; i++)
            {
                //' legge il carattere i-esimo
                char c = strExpression[i];

                if (c == '#')
                {
                    if (!b)
                    {
                        b = true;
                        j = i;
                    }
                    else
                    {
                        b = false;
                        string strItem = strExpression.Substring(j + 1, i - j - 1);

                        if (!Coll.ContainsKey(strItem))
                        {
                            Coll.Add(strItem, strItem);
                        }
                    }
                }
            }

            //' -- STEP 2: scorre la collezione dei campi da calcolare e poi li rimpiazza nell'espressione con il valore

            foreach (var item in Coll)
            {
                ss = item.Value.Split(".");
                string strTipo = ss[0].ToUpper();
                string strField = ss[1];
                string strSql = "";

                TSRecordSet? rs;
                string value = "";

                switch (strTipo)
                {
                    case "DOCUMENT":

                        Valore = "";

                        if (objDocument is null)
                        {
                            throw new NullReferenceException("clsSendMail.SetAttribValues: objDocument NULL");
                        }

						if (!objDocument.ColumnExists(strField))
                        {
							throw new Exception($"clsSendMail.SetAttribValues: {strField} not found in objDocument");
						}

						if (!IsNull(GetValueFromRS(objDocument.Fields[strField])))
                        {
                            //' -- vede se il campo ha un contenuto formattato html
                            //' -- in quel caso non deve fare nessun encode
                            bool bHtml = false;

                            if (ss.GetUpperBound(0) >= 2 && ss[2] == "HTML")
                            {
                                bHtml = true;
                            }

                            if (bHtml)
                            {
                                Valore = objDocument[strField]!;
                            }
                            else
                            {
                                Valore = NL_To_BR(HtmlEncode(CStr(objDocument[strField])));
                            }
							Valore = Replace(Valore, "#", "~~@@@~~");
						}

                        strExpression = Replace(strExpression, $"#{item.Value}#", Valore, 1, -1, Microsoft.VisualBasic.CompareMethod.Text);

                        break;

                    //'-- Per i casi in cui viene ritornato volutamente dell'html dal database
                    case "DOCUMENTHTML":
                        Valore = string.Empty;
						if (objDocument is null)
						{
							throw new NullReferenceException("clsSendMail.SetAttribValues: objDocument NULL");
						}

						if (!objDocument.ColumnExists(strField))
						{
							throw new Exception($"clsSendMail.SetAttribValues: {strField} not found in objDocument");
						}

						if (objDocument[strField] is not null)
						{
                            Valore = objDocument[strField]!;
                        }

                        strExpression = Replace(strExpression, $"#{item.Value}#", Valore, 1, -1, Microsoft.VisualBasic.CompareMethod.Text);
                        break;

                    case "COMPANY_FIX":

                    case "ML":

                        strSql = "select dbo.CNV_ESTESA( ML_Description , @strLanguage ) as ML_Description from LIB_Multilinguismo where ML_KEY = @strField and ML_LNG = @strLanguage";

                        var paramsSQL = new Dictionary<string, object?>();
                        paramsSQL.Add("@strLanguage", strLanguage);
                        paramsSQL.Add("@strField", strField);

                        rs = cdf.GetRSReadFromQueryWithTransaction(strSql, cnLocal.ConnectionString, cnLocal, transaction, iTimeout, paramsSQL);

                        value = string.Empty;

                        if (rs is not null && !(rs.EOF && rs.BOF))
                        {
                            rs.MoveFirst();

                            value = CStr(rs["ML_Description"]);
                        }
                        else
                        {
                            if (strLanguage != "I")
                            {
                                strSql = "select dbo.CNV_ESTESA( ML_Description ,'I') as ML_Description from LIB_Multilinguismo with(nolock) where ML_KEY = @strField and ML_LNG = 'I'";

                                paramsSQL.Clear();
                                paramsSQL.Add("@strField", strField);

                                rs = cdf.GetRSReadFromQueryWithTransaction(strSql, cnLocal.ConnectionString, cnLocal, transaction, iTimeout, paramsSQL);

                                if (rs is not null && !(rs.EOF && rs.BOF))
                                {
                                    rs.MoveFirst();
                                    value = CStr(rs["ML_Description"]);
                                }
                            }
                        }

                        //'-- solo se nn ho trovato la key metto i "???"
                        if (rs.RecordCount == 0)
                        {
                            value = $"???{strField}???";
                        }

                        strExpression = Replace(strExpression, $"#{item.Value}#", value, 1, -1, Microsoft.VisualBasic.CompareMethod.Text);

                        break;

                    case "SYS":

                        var sqlParams = new Dictionary<string, object?>();
                        sqlParams.Add("@DztName", strField);

                        strSql = "select DZT_ValueDef  as ML_Description from lib_dictionary with(nolock) where dzt_name = @DztName and dzt_module = 'Systema'";
                        rs = cdf.GetRSReadFromQueryWithTransaction(strSql, cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);

                        value = "";

                        if (rs is not null && !(rs.EOF && rs.BOF))
                        {
                            rs.MoveFirst();

                            value = CStr(rs["ML_Description"]);
                        }

                        //'--solo se non trovo la sys metto i "???"
                        if (rs.RecordCount == 0)
                        {
                            value = $"???{strField}???";
                        }

                        strExpression = Replace(strExpression, $"#{item.Value}#", value, 1, -1, Microsoft.VisualBasic.CompareMethod.Text);

                        break;

                    //case "USER_FIX":
                    //case "COMPANY_OPT":
                    //case "USER_OPT":
                    //case "TABAPPROVAL":
                    //case "GUID":

                    default:

                        Valore = "";
						if (objDocument is null)
						{
							throw new NullReferenceException("clsSendMail.SetAttribValues: objDocument NULL");
						}

						if (!objDocument.ColumnExists(strField))
						{
							throw new Exception($"clsSendMail.SetAttribValues: {strField} not found in objDocument");
						}

						if (objDocument[strField] is not null)
						{
                            Valore = NL_To_BR(HtmlEncode(CStr(objDocument[strField])));
                        }
						Valore = Replace(Valore, "#", "~~@@@~~");

						strExpression = Replace(strExpression, $"#{item.Value}#", Valore, 1, -1, Microsoft.VisualBasic.CompareMethod.Text);

                        break;
                }

                //'VALORE = FormattaValore(cnLocal, VALORE, strField)
                //
                //'strExpression = Replace(strExpression, "#" & coll(i) & "#", VALORE, , , vbTextCompare)
            }

            return strExpression;
        }

        private void GetAllegato(string keyAtt, SqlConnection cnLocal, SqlTransaction transaction, bool bchangeName)
        {
            //On Error GoTo err

            string[] stAtt = new string[] { };
            string strPath = "";

            stAtt = keyAtt.Split("*");

            //' prende l'allegato
            var sqlParams = new Dictionary<string, object?>();
            sqlParams.Add("@ATT_Hash", stAtt[3]);

            TSRecordSet rs = cdf.GetRSReadFromQueryWithTransaction("select ATT_IdRow from CTL_Attach with (nolock) where ATT_Hash=@ATT_Hash", cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);

            if (!(rs.EOF && rs.BOF))
            {
                rs.MoveFirst();

                string pathFolderAllegati = string.Empty;
                string filePath = string.Empty;

                try
                {

                    pathFolderAllegati = ConfigurationServices.GetKey("ApplicationContext:PathFolderAllegati", "")!;

                    if (string.IsNullOrEmpty(pathFolderAllegati))
                    {
                        string strSql = "select dzt_valuedef from lib_dictionary with (nolock) where dzt_name = 'SYS_PathFolderAllegati'";

                        TSRecordSet rs2 = cdf.GetRSReadFromQueryWithTransaction(strSql, cnLocal.ConnectionString, cnLocal, transaction, iTimeout);
                        if (!(rs2.EOF && rs2.BOF))
                        {
                            rs2.MoveFirst();
                            pathFolderAllegati = CStr(rs2["dzt_valuedef"]);
                        }
                    }

                    string file = CommonStorage.GetTempName();
                    if (bchangeName)
                        file = stAtt[0];

                    filePath = pathFolderAllegati + file;
                }
                catch (Exception ex)
                {
                    throw new Exception($"{ex.Message} - FUNZIONE : {MODULE_NAME}.GetAllegato", ex);
                }

                //' scrive l'allegato in un file
                strPath = ReadFromRecordsetWithPath("ATT_Obj", "CTL_Attach", "ATT_IdRow", CStr(rs["ATT_IdRow"]), filePath, cnLocal, transaction);

                // aggiunge alla lista
                if (IsEmpty(vAttachPath))
                    vAttachPath = new List<string>();

                if (IsEmpty(vAttachName))
                    vAttachName = new List<string>();

                vAttachPath.Add(strPath);
                vAttachName.Add(stAtt[0]);
            }
        }

        private string GetHtml(string strURL, bool bGetPath, ref string strPath, string strExtension, string strName = "", string connectionString = "")
        {
            string ret = string.Empty;
            string strError = string.Empty;
            string strTempPath = Path.GetTempPath();

            long lRet = 0;

            if (string.IsNullOrEmpty(strName))
            {
                strPath = Path.Combine(strTempPath, "\\", CommonStorage.GetTempName(), strExtension);
            }
            else
            {
                strPath = Path.Combine(strTempPath, "\\", strName, strExtension);
            }

            try
            {
                lRet = DownloadFileFromWebAsync(strURL, strPath).Result;

                if (lRet != 0)
                {
                    strError = $"Errore di download RetCode={lRet}";
                    LogEvent(TsEventLogEntryType.Error, $"Errore chiamata alla funzione di GetHtml: URL={strURL} - Num.err={lRet}", connectionString, "CtlProcess.clsSendMail");
                    strPath = "";
                    throw new Exception($"Errore chiamata alla funzione di GetHtml: URL={strURL} - Num.err={lRet}");
                }

                if (File.Exists(strPath))
                {
                    if (!bGetPath)
                    {
                        //'''''' PROBLEMA DI UNICODE
                        bool bUnicode = IsFileUnicode(strPath);

                        if (bUnicode)
                        {
                            ret = File.ReadAllText(strPath, Encoding.UTF8);
                        }
                        else
                        {
                            ret = File.ReadAllText(strPath);
                        }
                    }

                }
                else
                {
                    throw new Exception($"File Template Mail non trovato : {strPath}");
                }

                LogEvent(TsEventLogEntryType.Information, $"Recupero HTML OK codice ritorno={lRet}", connectionString, "CtlProcess.clsSendMail");
            }
            catch (Exception ex)
            {
                LogEvent(TsEventLogEntryType.Error, $"Errore GetHtml: URL={strURL} - Num.err={lRet}", connectionString, "CtlProcess.clsSendMail");
                throw new Exception($"Errore GetHtml: URL={strURL} - Num.err={lRet} - ex.Message : {ex.Message}", ex);
            }
            finally
            {
                if (CommonStorage.FileExists(strPath))
                {
                    CommonStorage.DeleteFile(strPath);
                }
            }

            return ret;
        }

        private void AddAttach(string strPath, string Name)
        {
            vAttachPath.Add(strPath);
            vAttachName.Add(Name);
        }

        private dynamic GetBodyMailFromFile(string strPath, string connectionString)
        {
            string ret = string.Empty;

            try
            {
                string s = string.Empty;

                //' determina il body della mail
                //' legge il file HTML
                string strFileName = strPath;

                if (CommonStorage.FileExists(strFileName))
                {
                    s = File.ReadAllText(strFileName);
                }
                else
                {
                    LogEvent(TsEventLogEntryType.Warning, $"ERRORE NON BLOCCANTE -- Non trovato file {strFileName} per costruire il body della mail - TipoDoc={mp_strTypeDoc} - ID={mp_strKeyDoc}", connectionString, "CtlProcess.clsSendMail");
                }

                ret = s;

                return ret;
            }
            catch (Exception ex)
            {
                throw new Exception($"{ex.Message} - FUNZIONE : {MODULE_NAME}.GetBodyMailFromFile", ex);
            }
        }

        private string GetParamValue(dynamic strKey)
        {
            if (mp_collParameters == null)
                return string.Empty;

            if (mp_collParameters.ContainsKey(strKey))
                return mp_collParameters[strKey];

            return string.Empty;
        }


        private bool IsUtenteAttivo(long lIdPfuDest, SqlConnection cnLocal, SqlTransaction transaction)
        {
            bool ret;

            var sqlParams = new Dictionary<string, object?>
            {
                { "@lIdPfuDest", lIdPfuDest }
            };

            //' vede se l'utente è attivo
            TSRecordSet? rsUser = cdf.GetRSReadFromQueryWithTransaction("select idPfu from ProfiliUtente with(nolock) Where idPfu = @lIdPfuDest And IsNull(pfuDeleted, 0) = 0", cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);

            if (rsUser.BOF && rsUser.EOF)
            {
                //' se non trova record vuol dire che l'utente è cancellato
                ret = false;
            }
            else
            {
                ret = true;
            }

            return ret;
        }

        private string NL_To_BR(string value)
        {
            value = value.Replace(Environment.NewLine, "</br>");
            value = value.Replace("\r", "</br>");
            value = value.Replace("\n", "</br>");

            return value;
        }

        private int GetIdTemplate(SqlConnection cnLocal, SqlTransaction transaction, string chiave)
        {
            int ret = 0;

            //On Error GoTo err

            var sqlParams = new Dictionary<string, object?>();
            sqlParams.Add("@MlKey", chiave);

            string strSql = "select id from CTL_Mail_Template with(nolock) where ML_KEY=@MlKey";
            TSRecordSet? rs = cdf.GetRSReadFromQueryWithTransaction(strSql, cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);

            if (rs is not null && !(rs.EOF && rs.BOF))
            {
                rs.MoveFirst();

                ret = CInt(rs["id"]!);
            }

            return ret;
        }

        //' se un indirizzo email è invalido torna vuoto
        //' in caso di elenco elimina gli indirizzi invalidi
        private string GetMaiAddressOK(string sMail)
        {
            //attenzione agli indirizzi multipli separati da
            string sOut = string.Empty;
            string[] vMail;
            string email = string.Empty;

            // On Error Resume Next

            vMail = sMail.Split(";");

            for (int i = 0; i < vMail.Length; i++)
            {
                email = vMail[i].Trim();

                try
                {
                    if (IsMailOk(email))
                    {
                        if (string.IsNullOrEmpty(sOut))
                        {
                            sOut = email;
                        }
                        else
                        {
                            sOut = $"{sOut};{email}";
                        }
                    }
                }
                catch (Exception ex)
                {
                    throw new Exception($"{ex.Message} - FUNZIONE : {MODULE_NAME}.GetMailAddressOK", ex);
                }

            }

            return sOut;
        }

        private bool IsMailOk(string sMail)
        {
            //' deve contenere la @ (una sola), prima della @ deve contenere almeno un carattere, dopo la @ deve contenere almeno un carattere e un .
            //' dopo il . finale deve contenere al massimo 4 caratteri ALFABETICI e minimo 2

            int i = 0;
            int j = 0;
            char pre = '\0';
            char post = '\0';
            string postDot = "";

            //' deve contenere la @
            i = sMail.IndexOf("@", StringComparison.Ordinal);
            if (i == -1)
            {
                return false;
            }

            //' deve contenere una sola @
            if (sMail.IndexOf("@", i + 1, StringComparison.Ordinal) != -1)
            {
                return false;
            }

            //'prima della @ deve contenere almeno un carattere
            pre = sMail[i - 1];
            post = sMail[i + 1];

            if (char.IsWhiteSpace(pre) || char.IsWhiteSpace(post))
            {
                return false;
            }

            //'dopo la @ deve contenere almeno un .
            j = sMail.IndexOf(".", i + 1, StringComparison.Ordinal);
            if (j == -1)
            {
                return false;
            }

            //' dopo il . finale deve contenere al massimo 4 caratteri ALFABETICI e minimo 2
            j = sMail.LastIndexOf(".", StringComparison.Ordinal);
            postDot = sMail.Substring(j + 1);

            //'RIMOSSI I 2 CONTROLLI SOTTOSTANTI DA FRANCESCO PER VIA DI UN BUG CON LA MAIL SU IC VME@PEC.VME.COMPANY
            //'NON VENIVANO INVIATE LE MAIL VERSO QUESTO INDIRIZZO
            //
            //
            //'If Len(postDot) < 2 Or Len(postDot) > 4 Then
            //'   Exit Function
            //'End If
            //
            //
            //'For k = 1 To Len(postDot)
            //'    If InStr(1, "qwertyuiopasdfghjklzxcvbnm", Mid(postDot, k, 1), vbTextCompare) <= 0 Then
            //'        Exit Function
            //'    End If
            //'Next k

            //' tra la @ e l'ultimo.ci deve essere almeno un char
            string tmp = sMail.Substring(i + 1, j - i - 1);
            if (tmp.Length == 0 || char.IsWhiteSpace(tmp[0]))
            {
                return false;
            }

            return true;
        }
    }
}
