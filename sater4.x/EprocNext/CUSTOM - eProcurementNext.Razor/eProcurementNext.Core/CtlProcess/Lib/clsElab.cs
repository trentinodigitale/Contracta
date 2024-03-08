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
    public class ClsElab
    {
        private readonly CommonDbFunctions cdf = new();
        private readonly DebugTrace dt = new();
        private int iTimeout = -1;

        public ELAB_RET_CODE Elaborate(string strProcessName, string strDocType, dynamic? strDocKey, long lIdPfu, ref string strDescrRetCode, dynamic? vIdMp = null, dynamic? vConnectionString = null, int timeout = -1)
        {
            ELAB_RET_CODE strReturn = ELAB_RET_CODE.RET_CODE_ERROR;
            string strCause = string.Empty;
            long strTempoTransazione = 0;
            string pathFolderAllegati = string.Empty;
            string strSqlLog;
            SqlConnection? cnLocal = null!;
            SqlTransaction? trans = null!;
            iTimeout = timeout;

            try
            {
                strTempoTransazione = DateTime.Now.Ticks;
                //    '-- se nel nome del processo è indicato il time out si separa il nome dal time out
                if (strProcessName.Contains(':', StringComparison.Ordinal))
                {
                    string[] vT = strProcessName.Split(":");
                    iTimeout = CInt(vT[1]);
                    strProcessName = vT[0];
                }

                strDescrRetCode = string.Empty;

                //    ' Apertura connessione
                strCause = "Apertura connessione al DB";

                if (vConnectionString == null)
                    vConnectionString = ApplicationCommon.Application.ConnectionString;
                cnLocal = cdf.SetConnection(CStr(vConnectionString));
                cnLocal.Open();

                trans = cnLocal.BeginTransaction(System.Data.IsolationLevel.ReadCommitted);

                //    ' recupera la sys  SYS_SERVIZIO per vedere se il servizio è stato bloccato
                string SYS_SERVIZIO = string.Empty;
                TSRecordSet rs = cdf.GetRSReadFromQueryWithTransaction("select dzt_valuedef from lib_dictionary with (nolock) where dzt_name = 'SYS_SERVIZIO'", CStr(vConnectionString), cnLocal, trans, iTimeout);
                if (!(rs.EOF && rs.BOF))
                {
                    rs.MoveFirst();
                    SYS_SERVIZIO = CStr(rs["dzt_valuedef"]);
                }
                else
                    //        ' se la sys manca per default l'applicazione è bloccata
                    SYS_SERVIZIO = "-";

                //    ' se il servizio è bloccato non si esegue nessun process
                if (SYS_SERVIZIO == "-")
                {
                    strReturn = ELAB_RET_CODE.RET_CODE_OK;
                    strReturn = Fine_Elaborate(cnLocal, trans, CStr(vConnectionString), strReturn, ref strTempoTransazione, ref strCause, strDocType, strProcessName, strDocKey, lIdPfu, "il servizio è bloccato non si esegue nessun process");

                    return strReturn;
                }

                pathFolderAllegati = ConfigurationServices.GetKey("ApplicationContext:PathFolderAllegati", "")!;

                if (string.IsNullOrEmpty(pathFolderAllegati))
                {
                    strSqlLog = "select dzt_valuedef from lib_dictionary with (nolock) where dzt_name = 'SYS_PathFolderAllegati'";
                    strCause = "recupero il valore della sys configurata SYS_PathFolderAllegati";

                    rs = cdf.GetRSReadFromQueryWithTransaction(strSqlLog, CStr(vConnectionString), cnLocal, trans, iTimeout);
                    if (!(rs.EOF && rs.BOF))
                    {
                        rs.MoveFirst();
                        pathFolderAllegati = CStr(rs["dzt_valuedef"]);
                    }
                }



                //    '----------------------------------------------------------------------------------------------------------------------
                //    '--- CONTROLLO DI SICUREZZA PER BLOCCARE UN UTENTE PRIVO DEL PERMESSO RICHIESTO PER L'ESECUZIONE DI UN DATO PROCESSO--
                //    '----------------------------------------------------------------------------------------------------------------------
                try
                {
                    var sqlParams = new Dictionary<string, object?>();
                    sqlParams.Add("@DocType", strDocType);
                    sqlParams.Add("@ProcessName", strProcessName);
                    sqlParams.Add("@IdPfu", CInt(lIdPfu));

                    strSqlLog = "EXEC AF_CHECK_PROCESS_PERMISSION @DocType, @ProcessName, @IdPfu";
                    rs = cdf.GetRSReadFromQueryWithTransaction(strSqlLog, CStr(vConnectionString), cnLocal, trans, iTimeout, sqlParams);
                    //    '-- Se non ci sono stati errori e se non otteniamo record in output vuol dire che dobbiamo bloccare l'esecuzione del processo
                    if (rs.RecordCount == 0)
                    {
                        mErrNumber = 999;
                        mErrSource = "CtlProcess.clsElab";
                        mErrDescription = $"Accesso non consentito al processo. Nessun record ritornato dallo script di controllo : {strSqlLog}";

                        CommonDB.Basic.LogEvent(CommonDB.Basic.TsEventLogEntryType.Error, mErrDescription, CStr(vConnectionString), mErrSource);

                        strDescrRetCode = "Non si possiedono i permessi sufficienti all'esecuzione del processo richiesto";
                        strReturn = Fine_Elaborate(cnLocal, trans, CStr(vConnectionString), strReturn, ref strTempoTransazione, ref strCause, strDocType, strProcessName, strDocKey, lIdPfu, strDescrRetCode);
                        return strReturn;
                    }
                }
                catch (Exception ex)
                {
                    dt.Write("Errore nel controllo di sicurezza AF_CHECK_PROCESS_PERMISSION : " + ex.ToString());
                }

                //    '--A MONTE verifico se ci sono sottoprocessi da chiamare in base ad una relazione REL_TYPE=PROCESS_PRE_EXECUTE
                string strRel_Type = "PROCESS_PRE_EXECUTE";

                strCause = $"A MONTE verifico se ci sono sottoprocessi da chiamare in base ad una relazione REL_TYPE=PROCESS_AFTER_EXECUTE-DOCTYPE={strDocType} PROCESSNAME={strProcessName}";
                strReturn = ExecActionsSubProcessRelation(cdf, cnLocal, strRel_Type, strProcessName, strDocType, strDocKey, lIdPfu, ref strDescrRetCode, ref strCause, vIdMp, iTimeout, trans);

                //    '--se tutto ok proseguo con il processo vero e proprio
                ELAB_RET_CODE strReturnCopy = strReturn;
                if (strReturnCopy == ELAB_RET_CODE.RET_CODE_OK)
                {
                    strReturn = ELAB_RET_CODE.RET_CODE_ERROR;
                    //        '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                    //        ' STEP 1 --- carica tutte le azioni per quel processo e tipo documento
                    //        '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                    strCause = $"Legge dal DB le azioni associate al Processo={strProcessName} , TipoDoc={strDocType}";

                    var sqlParams = new Dictionary<string, object?>();
                    sqlParams.Add("@DocType", strDocType);
                    sqlParams.Add("@ProcessName", strProcessName);

                    string strGetActionsProcess = "SELECT * FROM LIB_DocumentProcess WITH(NOLOCK) WHERE DPR_DOC_ID=@DocType AND DPR_ID=@ProcessName ORDER BY DPR_Order";
                    TSRecordSet rsActions = cdf.GetRSReadFromQueryWithTransaction(strGetActionsProcess, CStr(vConnectionString), cnLocal, trans, iTimeout, sqlParams);

                    if (rsActions == null || (rsActions.EOF && rsActions.BOF))
                    {
                        strDescrRetCode = "Nessuna azione associata al processo";
                        strReturn = Fine_Elaborate(cnLocal, trans, CStr(vConnectionString), strReturn, ref strTempoTransazione, ref strCause, strDocType, strProcessName, strDocKey, lIdPfu, strDescrRetCode);
                        return strReturn;
                    }

                    rsActions.MoveFirst();

                    //        '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                    //        ' STEP 2 --- esegue le azioni
                    //        '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                    strCause = $"Esegue le azioni associate al Processo={strProcessName}, TipoDoc={strDocType}";
                    dt.Write("clElab - riga 141 - " + strCause);
                    strReturn = ExecActionsProcess(cdf, ref cnLocal, rsActions, strDocType, strDocKey, lIdPfu, ref strDescrRetCode, ref strCause, vIdMp, CStr(vConnectionString), iTimeout, trans);
                    dt.Write("clElab - riga 143 - " + strReturn.ToString());
                }

                //    '--se tutto ok proseguo con eventuali sottoprocessi AFTER
                strReturnCopy = strReturn;
                if (strReturnCopy == ELAB_RET_CODE.RET_CODE_OK)
                {
                    strReturn = ELAB_RET_CODE.RET_CODE_ERROR;

                    //        '--A VALLE verifico se ci sono sottoprecessi da chiamare in base ad una relazione REL_TYPE=PROCESS_AFTER_EXECUTE
                    strRel_Type = "PROCESS_AFTER_EXECUTE";
                    strCause = $"A VALLE verifico se ci sono sottoprocessi da chiamare in base ad una relazione REL_TYPE=PROCESS_AFTER_EXECUTE-DOCTYPE={strDocType} PROCESSNAME={strProcessName}";
                    dt.Write("clElab - riga 155 - " + strCause);
                    strReturn = ExecActionsSubProcessRelation(cdf, cnLocal, strRel_Type, strProcessName, strDocType, strDocKey, lIdPfu, ref strDescrRetCode, ref strCause, vIdMp, iTimeout, trans);
                }
                dt.Write("clElab - riga 168 - RET=" + strReturn.ToString() + " - strCause=" + strCause);
                strReturn = Fine_Elaborate(cnLocal, trans, CStr(vConnectionString), strReturn, ref strTempoTransazione, ref strCause, strDocType, strProcessName, strDocKey, lIdPfu, "Fine Elaborate");
                dt.Write("clElab - riga 170 - RET=" + strReturn.ToString() + " - strCause=" + strCause);
            }
            catch (Exception ex)
            {
                string errDescription = ex.ToString();

                CommonDB.Basic.TraceErr(ex, CStr(vConnectionString), "clsElab");
				dt.Write($"clElab - traccia prima di WriteLogFile - {errDescription}");
				try
                {
                    //    '-- Scrittura fuori transazione per tracciarci il tempo totale in millisecondi che ha impiegato il processo per essere eseguito
                    strTempoTransazione = DateTime.Now.Ticks - strTempoTransazione;

                    trans.Rollback();
                    cnLocal.Close();
                }
                catch (Exception ex2)
                {
                    dt.Write("clElab - Eccezione in rollback trans/clone connection. Exception : " + ex2.ToString());
                }

                dt.Write($"clElab - pathFolderAllegati= {pathFolderAllegati}ctl_log_proc_errors.txt");
				try
                {
                    strSqlLog = $"{string.Format(DateTime.Now.ToString(), "yyyy-MM-dd H:m:s")} - [DOC_NAME = '{strDocType}',PROC_NAME = '{strProcessName}',id_Doc = '{CStr(strDocKey)}',idPfu = '{lIdPfu}'] : TEMPO:{strTempoTransazione} - STRCAUSE:{strCause} - ERR_DESCRIPTION:{errDescription}";

                    if (Trim(pathFolderAllegati) != string.Empty)
                    {
                        writeLogFile(strSqlLog, $"{pathFolderAllegati}ctl_log_proc_errors.txt");
                    }
                }
                catch (Exception ex2)
                {
                    throw new Exception($"Fallita scrittura Log File - {ex2} - FUNZIONE : CtlProcess.clsElab.Elaborate", ex2);
                }

                throw new Exception($"{strCause} - {ex.Message}  - FUNZIONE : CtlProcess.clsElab.Elaborate", ex);
            }

            return strReturn;
        }

        private ELAB_RET_CODE Fine_Elaborate(SqlConnection? conn, SqlTransaction? trans, string vConnectionString, dynamic strReturn, ref long strTempoTransazione, ref string strCause, string strDocType, string strProcessName, dynamic? strDocKey, long lIdPfu, string strStack)
        {
            strTempoTransazione = DateTime.Now.Ticks - strTempoTransazione;

            strCause = "Scrittura nel LOG";

            //    '-- Scrittura nel log per tracciarci il tempo totale in millisecondi che ha impiegato il processo per essere eseguito
            var sqlParams = new Dictionary<string, object?>();
            sqlParams.Add("@DocType", strDocType);
            sqlParams.Add("@ProcessName", strProcessName);
            sqlParams.Add("@DocKey", CStr(strDocKey));
            sqlParams.Add("@IdPfu", CInt(lIdPfu));
            sqlParams.Add("@TempoTrans", $"TEMPO:{CStr(strTempoTransazione)}");

            string strSqlLog = "insert into CTL_LOG_PROC (DOC_NAME, PROC_NAME, id_Doc, idPfu, Parametri) values (@DocType, @ProcessName, @DocKey, @IdPfu, @TempoTrans)";

            dt.Write("clsElab riga 213 - " + strStack + " - sqlLog= " + strSqlLog);

            cdf.ExecuteWithTransaction(strSqlLog, vConnectionString, conn, trans, iTimeout, sqlParams);

            //        ' se qualche step è andato male devo fare il rollback di tutto
            if (strReturn != ELAB_RET_CODE.RET_CODE_OK && strReturn != ELAB_RET_CODE.RET_CODE_BREAKANDCOMMIT)
            {
                strCause = "Invocazione RollbackTrans";
                trans!.Rollback();
            }
            else
            {
                strCause = "Invocazione CommitTrans";
                trans!.Commit();
            }

            //    ' Chiusura connessione
            strCause = "Chiusura connessione al DB";
            conn!.Close();

            return strReturn;
        }

        private void writeLogFile(string testo, string strFile)
        {
            if (CommonStorage.FileExists(strFile))
                CommonStorage.Write(strFile, testo);
        }
    }
}
