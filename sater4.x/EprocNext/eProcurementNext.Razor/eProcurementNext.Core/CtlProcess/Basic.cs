using Chilkat;
using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.CtlProcess.Interfaces;
using System.Data.SqlClient;
using System.Reflection;
using System.Text;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;

namespace eProcurementNext.CtlProcess
{
    public partial class Basic
    {
        private const string pathAssembly = "eProcurementNext.Core";
        private const string strNamespace = "eProcurementNext";

        public enum ARRAY_DOSSIER_POSITION
        {
            IND_MSG_ARTICOLI = 1,
            IND_MSG_VATART = 2,
            IND_MSG_VALORIATTRIBUTI = 3,
            IND_MSG_VALORIATTRIBUTI_DATETIME = 4,
            IND_MSG_VALORIATTRIBUTI_FLOAT = 5,
            IND_MSG_VALORIATTRIBUTI_DESCRIZIONI = 6,
            IND_MSG_VALORIATTRIBUTI_IMAGE = 7,
            IND_MSG_VALORIATTRIBUTI_INT = 8,
            IND_MSG_VALORIATTRIBUTI_KEYS = 9,
            IND_MSG_VALORIATTRIBUTI_MONEY = 10,
            IND_MSG_VALORIATTRIBUTI_NVARCHAR = 11,
            IND_MSG_VATMSG = 12
        }

        public enum MAIL_BODY_FORMAT
        {
            HTML = 0,
            TEXT = 1
        }

        public static async Task<long> DownloadFileFromWebAsync(string strURL, string strFileName)
        {
            return await URLDownloadToFileAsync(strURL, strFileName);
        }
        private static async Task<long> URLDownloadToFileAsync(string url, string strFileName)
        {
            try
            {
                HttpClient client = new HttpClient();
                client.Timeout = new TimeSpan(0, 0, 0, 0, 100000);
                var response = await client.GetAsync(url);

                //Se la request non è andata a buon fine
                if (response == null || !response.IsSuccessStatusCode)
                    return 1;

                using (var file = File.Create(strFileName))
                {
                    await response.Content.CopyToAsync(file);
                }
                return 0; //tutto ok
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message + " - FUNZIONE : CtlProcess.Basic.DownloadFileFromWeb", ex);
            }
        }

        public static ELAB_RET_CODE ExecActionsProcess(CommonDbFunctions cdf, ref SqlConnection cnLocal, TSRecordSet rsActions, string strDocType, dynamic strDocKey, long lIdPfu, ref string strDescrRetCode, ref string strCause, dynamic? vParam1 = null, dynamic? vParam2 = null, int timeOut = -1, SqlTransaction? transaction = null)
        {
            ELAB_RET_CODE retCode = ELAB_RET_CODE.RET_CODE_ERROR;

            try
            {
                string strProgId = string.Empty;
                string strParam = string.Empty;
                string strDescrStep = string.Empty;
                string errMessage = string.Empty;

                DebugTrace dt = new DebugTrace();

                //    ' ciclo sulle azioni
                while (!rsActions.EOF)
                {
                    strProgId = string.Empty;
                    strParam = string.Empty;
                    strDescrStep = string.Empty;

                    if (!string.IsNullOrEmpty(CStr(rsActions["DPR_ProgID"])))
                        strProgId = Trim(CStr(rsActions["DPR_ProgID"]));

                    strProgId = NormalizeProgIdProcess(strProgId);

                    if (!string.IsNullOrEmpty(Trim(CStr(rsActions["DPR_Param"]))))
                    {
                        strParam = Trim(CStr(rsActions["DPR_Param"]));

                        //            '-- Passiamo ai processi il timeOut recuperato dalla clsElab
                        if (timeOut > 0)
                            strParam = $"{strParam}#@#TIMEOUT#=#{CStr(timeOut)}";
                    }

                    if (!string.IsNullOrEmpty(Trim(CStr(rsActions["DPR_DescrStep"]))))
                        strDescrStep = Trim(CStr(rsActions["DPR_DescrStep"]));

                    strCause = $"Step: {strDescrStep} - Creazione oggetto {strProgId}";

                    string[] arrProgId = strProgId.Split(".");
                    Assembly asm = Assembly.Load(pathAssembly);

                    if (asm is not null)
                    {
                        Type? typeInstance = asm.GetType($"{strNamespace}.{strProgId}");

                        if (typeInstance is not null)
                        {
                            IProcess? classInstance = Activator.CreateInstance(typeInstance) as IProcess;
                            dt.Write("***REFLECTION: Basic.ExecActionsProcess riga 129 - classInstance=" + classInstance!.ToString());
                            retCode = classInstance.Elaborate(strDocType, strDocKey, lIdPfu, strParam, ref strDescrRetCode, vParam1, cnLocal, transaction, timeOut);
                        }
                        else
                        {
                            errMessage = $"Impossibile creare l'istanza di {strProgId}";
                            throw new Exception($"{errMessage} - FUNZIONE : Basic.ExecActionsProcess");
                        }
                    }
                    else
                    {
                        errMessage = $"Impossibile trovare l'assembly {pathAssembly}{arrProgId[0]}";
                        throw new Exception($"{errMessage} - FUNZIONE : Basic.ExecActionsProcess");
                    }

                    // chiama il metodo sull'oggetto che implementa l'azione
                    strCause = $"Step: {strDescrStep} ProgID={strProgId} - Chiamata al metodo Elaborate";

                    dt.Write($"Basic.ExecActionsProcess riga 146 - strDescrRetCode={strDescrRetCode} - strCause={strCause} - esito: {retCode}");

                    if (retCode != ELAB_RET_CODE.RET_CODE_OK)
                    {
                        return retCode;
                    }

                    rsActions.MoveNext();
                }

                return ELAB_RET_CODE.RET_CODE_OK;
            }
            catch (Exception ex)
            {
                throw new Exception($"{ex.Message} - FUNZIONE : Basic.ExecActionsProcess", ex);
            }
        }

        private static string NormalizeProgIdProcess(string progId)
        {
            string sRet = string.Empty;

            switch (progId.ToUpper())
            {
                case "CTLAPPROVALCYCLE.CLSAPPROVE":
                    sRet = "CtlApprovalCycle.ClsApprove";
                    break;
                case "CTLAPPROVALCYCLE.CLSNEXTAPPROVER":
                    sRet = "CtlApprovalCycle.ClsNextApprover";
                    break;
                case "CTLAPPROVALCYCLE.CLSNOTAPPROVE":
                    sRet = "CtlApprovalCycle.ClsNotApprove";
                    break;
                case "CTLAPPROVALCYCLE.CLSSENDTOBUYER":
                    sRet = "CtlApprovalCycle.ClsSendToBuyer";
                    break;
                case "CTLPROCESS.CLSCANSEND":
                    sRet = "CtlProcess.ClsCanSend";
                    break;
                case "CTLPROCESS.CLSCHECKANDUPD":
                    sRet = "CtlProcess.ClsCheckAndUpd";
                    break;
                case "CTLPROCESS.CLSCHECKPEC":
                    sRet = "CtlProcess.ClsCheckPec";
                    break;
                case "CTLPROCESS.CLSDECRYPTATTACH":
                    sRet = "CtlProcess.ClsDecryptAttach";
                    break;
                case "CTLPROCESS.CLSDOWNLOADER":
                    sRet = "CtlProcess.ClsDownloader";
                    break;
                case "CTLPROCESS.CLSEXPORTDOCUMENT":
                    sRet = "CtlProcess.ClsExportDocument";
                    break;
                case "CTLPROCESS.CLSGETPROTOCOL":
                    sRet = "CtlProcess.ClsGetProtocol";
                    break;
                case "CTLPROCESS.CLSGETRANDOM":
                    sRet = "CtlProcess.ClsGetRandom";
                    break;
                case "CTLPROCESS.CLSGETRIFERIMENTOPROTOCOLLO":
                    sRet = "CtlProcess.ClsGetRiferimentoProtocollo";
                    break;
                case "CTLPROCESS.CLSINVOKESERVICE":
                    sRet = "CtlProcess.ClsInvokeService";
                    break;
                case "CTLPROCESS.CLSLOADDOSSIER":
                    sRet = "CtlProcess.ClsLoadDossier";
                    break;
                case "CTLPROCESS.CLSMERGEPDF":
                    sRet = "CtlProcess.ClsMergePdf";
                    break;
                case "CTLPROCESS.CLSMULTISERVICE":
                    sRet = "CtlProcess.ClsMultiService";
                    break;
                case "CTLPROCESS.CLSSENDFAX":
                    sRet = "CtlProcess.ClsSendFax";
                    break;
                case "CTLPROCESS.CLSSENDGD":
                    sRet = "CtlProcess.ClsSendGD";
                    break;
                case "CTLPROCESS.CLSSENDMAIL":
                    sRet = "CtlProcess.ClsSendMail";
                    break;
                case "CTLPROCESS.CLSSETVALUE":
                    sRet = "CtlProcess.ClsSetValue";
                    break;
                case "CTLPROCESS.CLSSETVALUEXML":
                    sRet = "CtlProcess.ClsSetValueXml";
                    break;
                case "CTLPROCESS.CLSSUBPROCESS":
                    sRet = "CtlProcess.ClsSubProcess";
                    break;
                case "CTLPROCESS.CLSVBSCRIPT":
                    sRet = "CtlProcess.ClsVBScript";
                    break;
                case "CTLPROCESS.CLSVERIFYSIGN":
                    sRet = "CtlProcess.ClsVerifySign";
                    break;
                case "CTLPROCESS.CTLMAILSYSTEM":
                    sRet = "CtlProcess.CtlMailSystem";
                    break;
                default:
                    sRet = progId;
                    break;
            }

            return sRet;
        }

        //--esegue una serie di sottoprocessi configurati in una relazione
        //--strRel_Type = PROCESS_PRE_EXECUTE/PROCESS_AFTER_EXECUTE
        public static dynamic ExecActionsSubProcessRelation(CommonDbFunctions cdf, SqlConnection cnLocal, string strRel_Type, string strProcessName, string strDocType, dynamic? strDocKey, long lIdPfu, ref string strDescrRetCode, ref string strCause, dynamic? vParam1 = null, long timeOut = 0, SqlTransaction? transaction = null)
        {
            ELAB_RET_CODE retCode = ELAB_RET_CODE.RET_CODE_ERROR;
            string strProgId = string.Empty;
            string strParam = string.Empty;
            string strDescrStep = string.Empty;
            string strSql = string.Empty;
            string errMessage = string.Empty;

            try
            {
                //    '--eseguo la query per vedere se ci sono sottoprocessi da eseguire
                strCause = $"eseguo la query per vedere se ci sono sottoprocessi da eseguire - REL_TYPE={strRel_Type} - REL_VALUEINPUT={strDocType}-{strProcessName}";

                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@Rel_Type", strRel_Type);
                sqlParams.Add("@ValueInput", $"{Trim(strDocType)}-{Trim(strProcessName)}");

                strSql = "select rel_valueoutput from CTL_RELATIONS with(nolock) where rel_type=@Rel_Type and rel_valueInput=@ValueInput and isnull(rel_valueoutput,'') <> ''";
                TSRecordSet rsSubProcess;
                if (transaction == null)
                    rsSubProcess = cdf.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString, cnLocal, parCollection: sqlParams);
                else
                    rsSubProcess = cdf.GetRSReadFromQueryWithTransaction(strSql, ApplicationCommon.Application.ConnectionString, cnLocal, transaction, parCollection: sqlParams);

                //    '--setto fisso il progid per i sottoprocessi
                strProgId = NormalizeProgIdProcess("CtlProcess.ClsSubProcess");

                dynamic aInfo;

                if (rsSubProcess.RecordCount > 0)
                {
                    rsSubProcess.MoveFirst();

                    //        ' ciclo sui sottoprocessi
                    while (!rsSubProcess.EOF)
                    {
                        strParam = string.Empty;
                        strDescrStep = string.Empty;

                        aInfo = CStr(rsSubProcess["rel_valueoutput"]).Split("-");

                        strParam = $"DOC_NAME#=#{aInfo[0]}#@#PROC_NAME#=#{aInfo[1]}#@#NEW_PROCESS#=#yes";

                        //-- Passiamo ai processi il timeOut recuperato dalla clsElab
                        if (timeOut > 0)
                            strParam = $"{strParam}#@#TIMEOUT#=#{CStr(timeOut)}";

                        strCause = $"Step: SubProcess - Creazione oggetto {strProgId} - param = {strParam}";

                        string[] arrProgId = strProgId.Split(".");
                        Assembly asm = Assembly.Load(pathAssembly);

                        if (asm is not null)
                        {
                            Type? typeInstance = asm.GetType($"{strNamespace}.{strProgId}");

                            if (typeInstance is not null)
                            {
                                IProcess? classInstance = Activator.CreateInstance(typeInstance) as IProcess;
                                retCode = classInstance!.Elaborate(strDocType, strDocKey, lIdPfu, strParam, ref strDescrRetCode, vParam1, cnLocal, transaction);
                            }
                            else
                            {
                                errMessage = $"Impossibile creare l'istanza di {strProgId}";
                                throw new Exception($"{errMessage} - FUNZIONE : Basic.ExecActionsProcess");
                            }
                        }
                        else
                        {
                            errMessage = $"Impossibile trovare l'assembly {pathAssembly}{arrProgId[0]}";
                            throw new Exception($"{errMessage} - FUNZIONE : Basic.ExecActionsProcess");
                        }

                        if (retCode != ELAB_RET_CODE.RET_CODE_OK)
                        {
                            return retCode;
                        }

                        rsSubProcess.MoveNext();
                    }
                }

                retCode = ELAB_RET_CODE.RET_CODE_OK;
            }
            catch (Exception ex)
            {
                throw new Exception($"{ex.Message} - FUNZIONE : Basic.ExecActionsSubProcessRelation", ex);
            }
            return retCode;
        }

        public static TSRecordSet GetActionsProcess(CommonDbFunctions cdf, SqlConnection conn, string strProcessName, string strDocType, SqlTransaction? trans = null)
        {
            try
            {
                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@DocType", strDocType);
                sqlParams.Add("@ProcessName", strProcessName);

                string strSql = "SELECT * FROM LIB_DocumentProcess WITH(NOLOCK) WHERE DPR_DOC_ID=@DocType AND DPR_ID=@ProcessName ORDER BY DPR_Order";
                TSRecordSet rs;
                if (trans is null)
                    rs = cdf.GetRSReadFromQuery_(strSql, conn.ConnectionString, conn, parCollection: sqlParams);
                else
                    rs = cdf.GetRSReadFromQueryWithTransaction(strSql, conn.ConnectionString, conn, trans, parCollection: sqlParams);

                return rs;
            }
            catch (Exception ex)
            {
                throw new Exception($"{ex.Message} - FUNZIONE : CtlProcess.Basic.GetActionsProcess", ex);
            }
        }

        public static string GetSQLPrefixStatement(dynamic? param = null)
        {
            return $"SET NOCOUNT ON {Environment.NewLine}";
        }

        public static void CloseConnection(SqlConnection conn)
        {
            if (conn is not null && conn.State == System.Data.ConnectionState.Open)
                conn.Close();
        }

        public static string GetSys(SqlConnection cnLocal, string strName, SqlTransaction transaction)
        {
            string ret = string.Empty;

            try
            {
                var cdf = new CommonDB.CommonDbFunctions();

                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@Name", strName);
                TSRecordSet rs = cdf.GetRSReadFromQueryWithTransaction("select dzt_valuedef from lib_dictionary with(nolock) where dzt_name = @Name", cnLocal.ConnectionString, cnLocal, transaction, parCollection: sqlParams);

                if (!(rs.EOF && rs.BOF))
                {
                    rs.MoveFirst();

                    if (CStr(rs["dzt_valuedef"]) is not null)
                    {
                        ret = Trim(CStr(rs["dzt_valuedef"]));
                    }
                }

                return ret;
            }
            catch (Exception ex)
            {
                throw new Exception($"{ex.Message} - FUNZIONE : CtlProcess.Basic.GetSys", ex);
            }
        }

        public static void GetTableInfo(CommonDbFunctions cdf, SqlConnection conn, SqlTransaction? trans, string strDocType, ref string strTableName, ref string strFieldIDName)
        {
            try
            {
                strTableName = string.Empty;
                strFieldIDName = string.Empty;

                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@DocType", strDocType);

                TSRecordSet rs = cdf.GetRSReadFromQueryWithTransaction("SELECT doc_table,doc_fieldid FROM LIB_Documents with(nolock) WHERE DOC_ID=@DocType", conn.ConnectionString, conn, trans, parCollection: sqlParams);

                if (rs.RecordCount == 0)
                {
                    rs = cdf.GetRSReadFromQueryWithTransaction("SELECT doc_table,doc_fieldid FROM CTL_Documents with(nolock) WHERE DOC_ID=@DocType", conn.ConnectionString, conn, trans, parCollection: sqlParams);
                }

                if (!(rs.EOF && rs.BOF))
                {
                    rs.MoveFirst();
                    strTableName = CStr(rs["doc_table"]);
                    strFieldIDName = CStr(rs["doc_fieldid"]);
                }

            }
            catch (Exception ex)
            {
                throw new Exception($"{ex.Message} - FUNZIONE : CtlProcess.Basic.GetTableInfo", ex);
            }
        }

        public static bool IsFileUnicode(string strPath)  //, object fs)
        {
            bool bReturn = false;
            string fileText = string.Empty;

            try
            {
                StreamReader reader = new StreamReader(strPath);
                try
                {
                    do
                    {
                        fileText = $"{fileText}{reader.ReadLine()}";
                    }
                    while (reader.Peek() != -1);
                }
                catch
                {

                }
                finally
                {
                    reader.Close();
                }

                if (Len(Trim(fileText)) > 0)
                {
                    Encoding u16LE = Encoding.Unicode;
                    byte[] bytes = u16LE.GetBytes(fileText);
                    if (bytes[0] == 255 && bytes[1] == 254)
                        return true;
                }
                //            int iFile As Integer
                //Dim arrBuffer() As Byte
                //Dim s As String
                //Dim lngFileLen As Long
                //Dim v As Variant



                //iFile = FreeFile()
                //Open strPath For Binary Access Read As iFile
                //lngFileLen = FileLen(strPath)
                //ReDim arrBuffer(lngFileLen)

                //Get iFile, , arrBuffer
                //v = arrBuffer
                //Close iFile


                //' testa i primi due byte per vedere se il file è UNICODE
                //If lngFileLen >= 1 Then
                //    If v(0) = 255 And v(1) = 254 Then
                //        IsFileUnicode = True
                //    End If
                //End If
            }
            catch { }

            return bReturn;
        }

        public static string GetDefaultConnectionString()
        {
            return ApplicationCommon.Application.ConnectionString;
        }

        public static SqlConnection SetConnection(dynamic connection, CommonDbFunctions cdf)
        {
            if (connection is null)
            {
                connection = GetDefaultConnectionString();
                return cdf.SetConnection(connection);
            }
            else if (connection is SqlConnection)
                return connection;
            else
                return cdf.SetConnection(connection);
        }

        public static string cifraFile(string pathFileInput, string pathFileOutput, string IdDoc, bool cifra, SqlConnection cnLocal, long lIdPfu, SqlTransaction? trans = null)
        {
            string strReturn = string.Empty;
            CommonDbFunctions cdf = new();
            string cryptoKey = string.Empty;
            string strLocalCause = string.Empty;
            var sqlParams = new Dictionary<string, object?>();

            try
            {
                strLocalCause = "CreateObject AFLinkCrypt.Cifratura";
                Cifratura objCifratura = new();

                strLocalCause = "Insert log utente di recupero chiave";

                sqlParams.Add("@IdDoc", IdDoc);
                string strSQL = "insert into CTL_LOG_UTENTE (paginaDiArrivo, querystring, datalog) values ('ATTACH-RECUPERO-CHIAVE-CIFRATURA', @IdDoc, getdate())";

                if (trans is null)
                {
                    cdf.Execute(strSQL, cnLocal.ConnectionString, cnLocal, parCollection: sqlParams);
                }
                else
                {
                    cdf.ExecuteWithTransaction(strSQL, cnLocal.ConnectionString, cnLocal, trans, parCollection: sqlParams);
                }

                strLocalCause = "Chiamata a getChiaveDiCifratura";
                cryptoKey = getChiaveDiCifratura(IdDoc, cnLocal, lIdPfu, cdf, trans);

                strLocalCause = "Insert nel log di esito getChiaveDiCifratura";
                sqlParams.Clear();
                sqlParams.Add("@cryptoKey", cryptoKey);
                strSQL = "insert into CTL_LOG_UTENTE (paginaDiArrivo, querystring, datalog) values ('ATTACH-ESITO-CHIAVE-CIFRATURA', @cryptoKey, getdate())";

                if (trans is null)
                {
                    cdf.Execute(strSQL, cnLocal.ConnectionString, cnLocal, parCollection: sqlParams);
                }
                else
                {
                    cdf.ExecuteWithTransaction(strSQL, cnLocal.ConnectionString, cnLocal, trans, parCollection: sqlParams);
                }

                strLocalCause = "Invocazione metodo cifraturaFile";
                strReturn = objCifratura.CifraturaFile(pathFileInput, pathFileOutput, cryptoKey, cifra, string.Empty);

                if (Len(Trim(strReturn)) > 0)
                {
                    strLocalCause = "Insert log utente di trace errore";

                    sqlParams.Clear();
                    sqlParams.Add("@strReturn", strReturn);
                    strSQL = "insert into CTL_LOG_UTENTE (paginaDiArrivo, querystring, datalog) values ('ATTACH-ERRORE-ESITO-CIFRA-FILE' , @strReturn, getdate())";

                    if (trans is null)
                        cdf.Execute(strSQL, cnLocal.ConnectionString, cnLocal, parCollection: sqlParams);
                    else
                        cdf.ExecuteWithTransaction(strSQL, cnLocal.ConnectionString, cnLocal, trans, parCollection: sqlParams);
                }

                return strReturn;
            }
            catch (Exception ex)
            {
                string strError = $"{strLocalCause} - {ex.Message}";
                sqlParams.Clear();
                sqlParams.Add("@strError", strError);
                string strSQL = "insert into CTL_LOG_UTENTE (paginaDiArrivo, querystring, datalog) values ('ATTACH-ERRORE-ESITO-CIFRA-FILE' , @strError, getdate())";

                if (trans is null)
                    cdf.Execute(strSQL, cnLocal.ConnectionString, cnLocal, parCollection: sqlParams);
                else
                    cdf.ExecuteWithTransaction(strSQL, cnLocal.ConnectionString, cnLocal, trans, parCollection: sqlParams);

                throw new Exception($"{strError} - FUNZIONE : CtlProcess.Basic.cifraFile", ex);
            }
        }

        private static string getChiaveDiCifratura(string IdDoc, SqlConnection cnLocal, long lIdPfu, CommonDbFunctions cdf, SqlTransaction? trans = null)
        {
            string strReturn = string.Empty;
            string strSql = string.Empty;

            strSql = "Exec AFS_CRYPT_KEY_ATTACH  @lIdPfu , @IdDoc , 'ctl_doc' ";

            TSRecordSet rs;

            Dictionary<string, object?> sqlParams = new Dictionary<string, object?>();
            sqlParams.Add("@lIdPfu", lIdPfu);
            sqlParams.Add("@IdDoc", IdDoc);

            if (trans == null)
                rs = cdf.GetRSReadFromQuery_(strSql, cnLocal.ConnectionString, cnLocal, parCollection: sqlParams);
            else
                rs = cdf.GetRSReadFromQueryWithTransaction(strSql, cnLocal.ConnectionString, cnLocal, trans, parCollection: sqlParams);

            if (rs.RecordCount > 0)
            {
                rs.MoveFirst();
                strReturn = CStr(rs["chiave"]);

                if (Len(Trim(strReturn)) == 0)
                    throw new Exception("chiave di cifratura vuota" + " - FUNZIONE : CtlProcess.Basic.getChiaveDiCifratura");
            }
            else
            {
                throw new Exception("errore recupero chiave di cifratura" + " - FUNZIONE : CtlProcess.Basic.getChiaveDiCifratura");
            }

            return strReturn;
        }



        public static string minimalUrlEncode(string urlParam)
        {
            string strReturn = string.Empty;
            try
            {
                strReturn = Replace(urlParam, " ", "%20");
                strReturn = Replace(strReturn, @"""", @"%22");
                strReturn = Replace(strReturn, "&", "%26");
                strReturn = Replace(strReturn, "<", "%3C");
                strReturn = Replace(strReturn, ">", "%3E");
                strReturn = Replace(strReturn, "è", "%C3%A8");
                strReturn = Replace(strReturn, "ò", "%C3%B2");
                strReturn = Replace(strReturn, "à", "%C3%A0");
                strReturn = Replace(strReturn, "+", "%2B");
                strReturn = Replace(strReturn, "ù", "%C3%B9");
                strReturn = Replace(strReturn, "#", "%23");
                strReturn = Replace(strReturn, @"\", @" % 5C");
                strReturn = Replace(strReturn, "/", "%2F");
                strReturn = Replace(strReturn, ":", "%3A");

                return strReturn;
            }
            catch
            {
                return urlParam;
            }
        }

        public static string ReadFromRecordsetWithPath(string fldName, string tableName, string colIdentity, string key, string filePath, SqlConnection? conn = null, SqlTransaction? trans = null)
        {
            string sRet = string.Empty;

            try
            {
                eProcurementNext.CommonDB.Basic.saveFileFromRecordSet(fldName, tableName, colIdentity, key, filePath, conn, trans);

                sRet = filePath;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message, ex);
            }

            return sRet;
        }

        public static string RefreshToken(string jsonToken, string tokenEndpoint, string clientId, string clientSecret)
        {
            string ret = jsonToken;

            try
            {
                Imap imap = new();
                imap.UnlockComponent(Email.Basic.GetUnlockKey(ApplicationCommon.Configuration));

                JsonObject objJsonToken = new();
                objJsonToken.Load(jsonToken);

                OAuth2 oauth2 = new();
                oauth2.TokenEndpoint = tokenEndpoint;
                oauth2.ClientId = clientId;
                oauth2.ClientSecret = clientSecret;
                oauth2.RefreshToken = objJsonToken.StringOf("refresh_token");
                bool success = oauth2.RefreshAccessToken();
                if (!success)
                {
                    throw new Exception($"RefreshAccessToken: {oauth2.LastErrorText} - FUNZIONE : {strNamespace}.CtlProcess.Basic.RefreshToken");
                }

                objJsonToken.UpdateString("access_token", oauth2.AccessToken);
                objJsonToken.UpdateString("refresh_token", oauth2.RefreshToken);

                string newToken = objJsonToken.Emit();

                // aggiorna il token passato nei parametri
                ret = newToken;

                return ret;
            }
            catch (Exception ex)
            {
                throw new Exception($"{ex.Message} - FUNZIONE : {strNamespace}.CtlProcess.Basic.RefreshToken", ex);
            }
        }

        public static bool ConnectImapOffice365Smtp(string jsonToken, MailMan mailman, Chilkat.Email email, out string strErrore)
        {
            bool ret = false;
            strErrore = string.Empty;

            try
            {
                JsonObject objJsonToken = new();
                bool success = objJsonToken.Load(jsonToken);

                if (!success)
                {
                    throw new Exception($"ConnectImapOffice365Smtp: {objJsonToken.LastErrorText} - FUNZIONE : {strNamespace}.CtlProcess.Basic.ConnectImapOffice365Smtp");
                }

                MailMan mailman2 = new MailMan();
                mailman2.UnlockComponent(Email.Basic.GetUnlockKey(ApplicationCommon.Configuration));
               
                mailman2.SmtpHost = mailman.SmtpHost;
                mailman2.SmtpPort = mailman.SmtpPort;
                mailman2.StartTLS = mailman.StartTLS;
                mailman2.SmtpUsername = mailman.SmtpUsername;

                mailman2.OAuth2AccessToken = objJsonToken.StringOf("access_token");

                success = mailman2.SendEmail(email);

                if (!success)
                {
                    strErrore = $"ConnectImapOffice365Smtp::Error SendMail:: host= {mailman2.SmtpHost} - UserName={mailman2.SmtpUsername} - Porta={mailman2.SmtpPort} - StartTLS={mailman2.StartTLS} - SSL={mailman2.SmtpSsl} :: {mailman2.LastErrorText}";
                    mailman2.CloseSmtpConnection();
                    return ret;
                }

                mailman2.CloseSmtpConnection();

                ret = true;
                return ret;
            }
            catch (Exception ex)
            {
                throw new Exception($"{ex.Message} - FUNZIONE : {strNamespace}.CtlProcess.Basic.ConnectImapOffice365Smtp", ex);
            }
        }
    }
}