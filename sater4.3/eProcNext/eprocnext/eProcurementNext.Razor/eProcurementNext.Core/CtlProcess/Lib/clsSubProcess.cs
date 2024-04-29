using eProcurementNext.CommonDB;
using System.Data.SqlClient;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;
using static eProcurementNext.CtlProcess.Basic;

namespace eProcurementNext.CtlProcess
{
    internal class ClsSubProcess : ProcessBase
    {
        private readonly CommonDbFunctions cdf = new();
        private Dictionary<string, string>? mp_collParameters = null;
        long mp_lIdPfu = 0;

        private const string MODULE_NAME = "CtlProcess.ClsSubProcess";

        //-- parametri da configurare sull'azione del processo
        private const string DOC_NAME = "DOC_NAME"; //-- contiene il tipo di documento su cui eseguire il processo
        private const string PROC_NAME = "PROC_NAME"; //-- contiene il nome del processo da eseguire
        private const string QUERY_CONDITION = "QUERY_CONDITION"; //-- facoltativo, contiene la query che se non ritorna righe vuol dire che è falsa e non effettua i settaggi richiesti
        private const string NEW_PROCESS = "NEW_PROCESS"; //-- facoltativo, contiene yes se il sottoprocesso deve cambiare il tipo documento
        private const string QUERY_DOCKEY = "QUERY_DOCKEY"; //-- facoltativo, contiene la query da eseguire per recuperare la key del doc "nella colonna DOCKEY"
        private const string MULTY_QUERY_DOCKEY = "MULTY_QUERY_DOCKEY"; //-- facoltativo, contiene yes se la query ritorna più id"

        private int iTimeout = -1;

        public override ELAB_RET_CODE Elaborate(string strDocType, dynamic strDocKey, long lIdPfu, string strParam, ref string strDescrRetCode, dynamic? vIdMp = null, dynamic? connection = null, SqlTransaction? transaction = null, int timeout = -1)
        {
            ELAB_RET_CODE strReturn = ELAB_RET_CODE.RET_CODE_ERROR;

            SqlConnection? cnLocal = null!;
            iTimeout = timeout;
            string LocStrDocType = strDocType;
            dynamic LocStrDocKey = strDocKey;
            dynamic? LocStrProcName = null;
            dynamic? LocStrDocName = strDocType;
            //sentinella per capire se passo al subprocess il parametro DOCNAME dinamicamente
            string? sentinella = "NO";
            long strTempoTransazione = 0;

            string strvalue;
            string strCause = string.Empty;

            try
            {
                string strSqlDockey = string.Empty;
                string strMultyDockey = string.Empty;
                string strSqlLog = string.Empty;

                strDescrRetCode = string.Empty;
                mp_lIdPfu = lIdPfu;

                // Apertura connessione
                strCause = "Apertura connessione al DB";
                cnLocal = SetConnection(connection, cdf);

                //    STEP 1 --- legge i parametri necessari
                strCause = "Lettura dei parametri che determinano le azioni";

                if (GetParameters(strParam, ref strDescrRetCode))
                {
                    //-- recupera il parametro per decidere se cambiare il nome del documento
                    if (mp_collParameters!.ContainsKey(PROC_NAME))
                        LocStrProcName = mp_collParameters[PROC_NAME];

                    strvalue = string.Empty;
                    if (mp_collParameters.ContainsKey(NEW_PROCESS))
                        strvalue = mp_collParameters[NEW_PROCESS];

                    if (!string.IsNullOrEmpty(strvalue) && mp_collParameters.ContainsKey(DOC_NAME))
                    {
                        LocStrDocType = mp_collParameters[DOC_NAME];
                        LocStrDocName = LocStrDocType;
                    }

                    //--recupero parametro che se passato mi fà recuperare la key del doc
                    strSqlDockey = string.Empty;
                    if (mp_collParameters.ContainsKey(QUERY_DOCKEY))
                        strSqlDockey = mp_collParameters[QUERY_DOCKEY];
                    if (mp_collParameters.ContainsKey(MULTY_QUERY_DOCKEY))
                        strMultyDockey = mp_collParameters[MULTY_QUERY_DOCKEY];

                    if (!string.IsNullOrEmpty(strSqlDockey))
                    {
                        strSqlDockey = (strSqlDockey.Replace("<ID_USER>", CStr(mp_lIdPfu))).Replace("<ID_DOC>", CStr(strDocKey));

                        TSRecordSet rs = cdf.GetRSReadFromQueryWithTransaction(strSqlDockey, CStr(connection), cnLocal, transaction, iTimeout);

                        if (rs.RecordCount > 0)
                        {
                            rs.MoveFirst();
                            LocStrDocKey = string.Empty;
                            LocStrProcName = string.Empty;
                            LocStrDocName = string.Empty;
                            sentinella = cdf.FieldExistsInRS(rs, "DOCNAME") ? CStr(rs["DOCNAME"]) : "NO";

                            if (Len(Trim(strMultyDockey)) > 0)
                            {
                                LocStrDocKey = rs["DOCKEY"]!;
                                LocStrProcName = cdf.FieldExistsInRS(rs, "PROCNAME") ? rs["PROCNAME"] : mp_collParameters[PROC_NAME];
                                LocStrDocName = cdf.FieldExistsInRS(rs, "DOCNAME") ? rs["DOCNAME"] : LocStrDocType;
                            }
                            else
                            {
                                while (!rs.EOF)
                                {
                                    string procName = string.Empty;
                                    string docName = string.Empty;

                                    LocStrDocKey = $"{LocStrDocKey}{rs["DOCKEY"]!},";

                                    procName = cdf.FieldExistsInRS(rs, "PROCNAME") ? CStr(rs["PROCNAME"]) : mp_collParameters[PROC_NAME];
                                    LocStrProcName = $"{LocStrProcName}{procName},";

                                    docName = cdf.FieldExistsInRS(rs, "DOCNAME") ? CStr(rs["DOCNAME"]) : LocStrDocType;
                                    LocStrDocName = $"{LocStrDocName}{docName},";

                                    rs.MoveNext();
                                }
                                LocStrDocKey = Left(LocStrDocKey, Len(LocStrDocKey) - 1);
                                LocStrProcName = Left(LocStrProcName, Len(LocStrProcName) - 1);
                                LocStrDocName = Left(LocStrDocName, Len(LocStrDocName) - 1);
                            }
                        }
                        else
                        {
                            strReturn = ELAB_RET_CODE.RET_CODE_OK;
                            return strReturn;
                        }
                    }

                    //        On Error GoTo err
                    //  STEP 2 --- Controllo della condizione per eseguire l' update dei valori richiesti
                    strCause = "Controllo della condizione per eseguire l'update dei valori richiesti";

                    if (CheckCondition(cnLocal, transaction, strDocKey))
                    {
                        //  STEP 3 --- carica tutte le azioni per quel processo e tipo documento
                        //            'Dim rsActions As ADODB.Recordset
                        string[] vKey = CStr(LocStrDocKey).Split(",");
                        string[] pKey = CStr(LocStrProcName).Split(",");
                        string[] dKey = CStr(LocStrDocName).Split(",");
                        int pVKey = pKey.Length;
                        string DIN_PROC_NAME = string.Empty;
                        string DIN_DOC_NAME = string.Empty;

                        for (int k = 0; k < pVKey; k++)
                        {
                            strTempoTransazione = DateTime.Now.Ticks;

                            DIN_PROC_NAME = pKey[k];
                            DIN_DOC_NAME = dKey[k];
                            string tipoDoc = sentinella == "NO" ? mp_collParameters[DOC_NAME] : DIN_DOC_NAME;
                            strCause = $"Legge dal DB le azioni associate al Processo={DIN_PROC_NAME} , TipoDoc={tipoDoc}";
                            TSRecordSet rsActions = GetActionsProcess(cdf, cnLocal, DIN_PROC_NAME, tipoDoc, transaction);

                            if (rsActions == null || (rsActions.EOF && rsActions.BOF))
                            {
                                strDescrRetCode = "Nessuna azione associata al processo";
                                strReturn = ELAB_RET_CODE.RET_CODE_ERROR;
                            }

                            rsActions!.MoveFirst();

                            // STEP 3 --- esegue le azioni
                            strCause = $"Esegue le azioni associate al Processo={DIN_PROC_NAME} , TipoDoc={DIN_DOC_NAME}";
                            strReturn = ExecActionsProcess(cdf, ref cnLocal, rsActions, DIN_DOC_NAME, vKey[k], lIdPfu, ref strDescrRetCode, ref strCause, vIdMp, cnLocal.ConnectionString, 0, transaction);

                            strTempoTransazione = DateTime.Now.Ticks - strTempoTransazione;

                            strCause = "Scrittura nel LOG";

                            //-- Scrittura nel log per tracciarci il tempo totale in millisecondi che ha impiegato il processo per essere eseguito
                            var sqlParams = new Dictionary<string, object?>();
                            sqlParams.Add("@DIN_DOC_NAME", DIN_DOC_NAME);
                            sqlParams.Add("@DIN_PROC_NAME", DIN_PROC_NAME);
                            sqlParams.Add("@vKey", vKey[k]);
                            sqlParams.Add("@lIdPfu", lIdPfu);
                            sqlParams.Add("@Tempo", $"TEMPO:{CStr(strTempoTransazione)}");
                            strSqlLog = "insert into CTL_LOG_PROC (DOC_NAME, PROC_NAME, id_Doc, idPfu, Parametri) values (@DIN_DOC_NAME, @DIN_PROC_NAME, @vKey, @lIdPfu, @Tempo)";

                            cdf.ExecuteWithTransaction(strSqlLog, cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);

                            // AGGIUNTA per gestire retcode dei processi chiamati ES. Chackupdate esco con il messaggio
                            if (strReturn != ELAB_RET_CODE.RET_CODE_OK)
                            {
                                break;
                            }
                        }
                    }
                    else
                    {
                        strReturn = ELAB_RET_CODE.RET_CODE_OK;
                    }
                }
            }
            catch (Exception ex)
            {
                CommonDB.Basic.TraceErr(ex, cnLocal.ConnectionString, MODULE_NAME);
                throw new Exception($"{strCause} - {ex.Message} - FUNZIONE : " + MODULE_NAME + ".Elaborate", ex);
            }
            return strReturn;
        }

        private bool GetParameters(string strParam, ref string strDescrRetCode)
        {
            bool bReturn = false;
            //    ' I parametri vengono passati come Field1=Valore1&Field2=Valore2....

            try
            {
                mp_collParameters = GetCollectionExt(strParam);

                //    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                //    ' controlli sui parametri passati
                //    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                if (!mp_collParameters.ContainsKey(DOC_NAME))
                {
                    strDescrRetCode = $"Manca il parametro input {DOC_NAME}";
                    return bReturn;
                }

                if (!mp_collParameters.ContainsKey(PROC_NAME))
                {
                    strDescrRetCode = $"Manca il parametro input {PROC_NAME}";
                    return bReturn;
                }

                bReturn = true;
            }
            catch (Exception ex)
            {
                throw new Exception($"{ex.Message} - FUNZIONE : {MODULE_NAME}.GetParameters", ex);
            }
            return bReturn;
        }

        private bool CheckCondition(SqlConnection conn, SqlTransaction trans, dynamic strDocKey)
        {
            bool bReturn = false;
            string strSql = string.Empty;

            if (!mp_collParameters!.ContainsKey(QUERY_CONDITION))
            {
                bReturn = true;
                return bReturn;
            }

            try
            {
                strSql = (mp_collParameters[QUERY_CONDITION].Replace("<ID_USER>", CStr(mp_lIdPfu))).Replace("<ID_DOC>", CStr(strDocKey));

                TSRecordSet rs = cdf.GetRSReadFromQueryWithTransaction(strSql, conn.ConnectionString, conn, trans, iTimeout);

                bReturn = !(rs.EOF && rs.BOF);

                return bReturn;
            }
            catch (Exception ex)
            {
                throw new Exception($"{ex.Message} - FUNZIONE : {MODULE_NAME}.CheckCondition", ex);
            }
        }
    }
}
