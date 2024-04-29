using eProcurementNext.Application;
using eProcurementNext.BizDB;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using System.Data;
using System.Data.SqlClient;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;
using static eProcurementNext.CtlProcess.Basic;

namespace eProcurementNext.CtlProcess
{
    internal class ClsGetProtocol : ProcessBase
    {
        private readonly CommonDbFunctions cdf = new CommonDbFunctions();
        string mp_strTableName = string.Empty;
        string mp_strFieldIDName = string.Empty;
        private Dictionary<string, string>? mp_collParameters = null!;
        string mp_QUERY_DOCKEY = string.Empty;

        private const string MODULE_NAME = "CtlProcess.ClsGetProtocol";

        //LIST_FIELDS#=#nuovo_dztname;;vecchio_dztname,, .........
        // ad esempio:
        //LIST_FIELDS#=#RDA_Protocol;;RDA_Protocol
        //FORMAT#=#0 se =0 oppure non esiste allora applico la formattazione altrimenti no
        //COL_IDAZI#=#col se  presente indica la colonna del documento che4 contiene idazi su cui voglio i contatori
        //COLS_FORSCRIPT#=#col1,...,colN se  presente indica le colonne della tabella del documento utili al calcolo dei contatori
        //TABNAME#=#tabella opzionale  la tabella su cui vado ad agire
        //FIELD_ID#=# opzionale colonna usata come perno sulla tabella
        //QUERY_DOCKEY#=# opzionale  la query che mi restituisce gli id delle righe su cui operare
        private const string LIST_FIELDS = "LIST_FIELDS";
        private const string FORMAT = "FORMAT";
        private const int LEN_NUMBER_PROTOCOL = 6;
        private const string COLS_FORSCRIPT = "COLS_FORSCRIPT";
        private const string TABNAME = "TABNAME";
        private const string FIELD_ID = "FIELD_ID";
        private const string QUERY_DOCKEY = "QUERY_DOCKEY";
        private const string COL_IDAZI = "COL_IDAZI";
        private int iTimeout = -1;

        public override ELAB_RET_CODE Elaborate(string strDocType, dynamic strDocKey, long lIdPfu, string strParam, ref string strDescrRetCode, dynamic? vIdMp = null, dynamic? connection = null, SqlTransaction? transaction = null, int timeout = -1)
        {
            ELAB_RET_CODE strReturn = ELAB_RET_CODE.RET_CODE_ERROR;

            SqlConnection? cnLocal = null!;
            DebugTrace dt = new();
            iTimeout = timeout;

            string strCause = string.Empty;

            try
            {
                dynamic? strDocKeyUltra = null;

                DbProfiler dbProfiler;


                strReturn = ELAB_RET_CODE.RET_CODE_ERROR;
                strDescrRetCode = string.Empty;

                strDocKeyUltra = strDocKey;

                if (vIdMp == null)
                {
                    strDescrRetCode = "Parametro MarketPlace non valorizzato";
                    return strReturn;
                }

                // Apertura connessione
                strCause = "Apertura connessione al DB";
                cnLocal = SetConnection(connection, cdf);

                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                // STEP 1 --- legge i parametri necessari
                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                strCause = "Lettura dei parametri che determinano le azioni";
                bool bOK = GetParameters(strParam, ref strDescrRetCode);

                if (!bOK)
                    return strReturn;

                //--se tabella e colonna perno nn sono passati li recupero dal documento
                if (Len(Trim(mp_strTableName)) == 0 && Len(Trim(mp_strFieldIDName)) == 0)
                {
                    //''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                    // STEP 2 --- cerca il nome della tabella dei documenti
                    //''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                    strCause = $"cerca il nome della tabella dei documenti per il tipo={strDocType}";
                    GetTableInfo(cdf, cnLocal, transaction, strDocType, ref mp_strTableName, ref mp_strFieldIDName);

                    if (Len(Trim(mp_strTableName)) == 0 || Len(Trim(mp_strFieldIDName)) == 0)
                    {
                        strDescrRetCode = "Tipo di documento non trovato nella LIB_Documents";
                        return strReturn;
                    }
                }


                //--se  presente una query faccio la replace
                if (Len(Trim(mp_QUERY_DOCKEY)) > 0)
                {
                    mp_QUERY_DOCKEY = mp_QUERY_DOCKEY.Replace("<ID_DOC>", CStr(strDocKey));
                    strDocKeyUltra = mp_QUERY_DOCKEY;

                    //--se la query non ritorna righe esco subito altrimenti brucio protocolli a vuoto
                    if (Len(Trim(CStr(strDocKeyUltra))) > 0)
                    {
                        dbProfiler = new DbProfiler(ApplicationCommon.Configuration);
                        dbProfiler.startProfiler();

                        TSRecordSet rsQuery = cdf.GetRSReadFromQueryWithTransaction(mp_QUERY_DOCKEY, cnLocal.ConnectionString, cnLocal, transaction, iTimeout);

                        dbProfiler.endProfiler();
                        dbProfiler.traceDbProfiler(mp_QUERY_DOCKEY, ApplicationCommon.Application.ConnectionString);// cnLocal.ConnectionString);

                        if (rsQuery.RecordCount == 0)
                        {
                            strReturn = ELAB_RET_CODE.RET_CODE_OK;
                            return strReturn;
                        }
                    }
                }

                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                // STEP 3 --- Calcola il valore del contatore per ogni campo input
                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                strCause = "Dimensiona gli array in base al numero di attributi da calcolare";

                string? strAlgoritmo = null;
                string vValues = String.Empty;

                string[]? ss = mp_collParameters![LIST_FIELDS].Split(",,");
                string[]? ww = null;

                ww = ss[0].Split(";;");
                string strNewDztName = ww[0];
                strAlgoritmo = ww[1];

                strCause = "Calcola il valore del contatore per ogni campo input";
                GetCountersValue(cnLocal, transaction, lIdPfu, vIdMp, strAlgoritmo, ref vValues, ref strDocKeyUltra);

                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                // STEP 4 --- Aggiorna i campi nella tabella
                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                strCause = "Aggiorna i campi contatore nella tabella";

                string strUpd = string.Empty;
                string strSET = string.Empty;

                strSET = strNewDztName + "='" + vValues + "'";

                strUpd = $"UPDATE {mp_strTableName} SET {strSET} WHERE {mp_strFieldIDName} in ({CStr(strDocKeyUltra)})";

                dbProfiler = new DbProfiler(ApplicationCommon.Configuration);
                dbProfiler.startProfiler();

                cdf.ExecuteWithTransaction(strUpd, cnLocal.ConnectionString, cnLocal, transaction, iTimeout);

                dbProfiler.endProfiler();
                dbProfiler.traceDbProfiler(strUpd, ApplicationCommon.Application.ConnectionString); //cnLocal.ConnectionString);

                strReturn = ELAB_RET_CODE.RET_CODE_OK;
            }
            catch (Exception ex)
            {
                CommonDB.Basic.TraceErr(ex, cnLocal.ConnectionString, MODULE_NAME);
                throw new Exception($"{strCause} - {ex.Message} - FUNZIONE : {MODULE_NAME}.Elaborate", ex);
            }

            dt.Write("clsGetProtocol riga 192 + strReturn: " + strReturn);
            return strReturn;
        }

        private bool GetParameters(string strParam, ref string strDescrRetCode)
        {
            bool bReturn = false;
            // I parametri vengono passati come Field1=Valore1&Field2=Valore2....

            try
            {
                mp_collParameters = GetCollectionExt(strParam);

                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                // controlli sui parametri passati
                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                // elenco attributi su cui innescare la chiamata ai contatori
                if (!mp_collParameters.ContainsKey(LIST_FIELDS))
                {
                    strDescrRetCode = $"Manca il parametro input {LIST_FIELDS}";
                    return bReturn;
                }

                //--tabella
                if (mp_collParameters.ContainsKey(TABNAME))
                    mp_strTableName = mp_collParameters[TABNAME];

                //--colonna perno
                if (mp_collParameters.ContainsKey(FIELD_ID))
                    mp_strFieldIDName = mp_collParameters[FIELD_ID];

                //--query per le righe su cui operare
                mp_QUERY_DOCKEY = string.Empty;
                if (mp_collParameters.ContainsKey(QUERY_DOCKEY))
                    mp_QUERY_DOCKEY = mp_collParameters[QUERY_DOCKEY];

                bReturn = true;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message + " - FUNZIONE : " + MODULE_NAME + ".GetParameters", ex);
            }
            return bReturn;
        }

        private void GetCountersValue(SqlConnection conn, SqlTransaction trans, long lIdPfu, dynamic? vIdMp, string strAlgoritmo, ref string vValues, ref dynamic? strDocKey)
        {
            string strCause = string.Empty;

            try
            {
                string strFormat = string.Empty;
                long lIdAzi = -1;
                string strColIdazi = string.Empty;

                //--recupero se specificato azienda x i contatori
                strCause = $"recupero se specificato azienda x i contatori: IDDOC= {CStr(strDocKey)}";
                if (mp_collParameters!.ContainsKey(COL_IDAZI))
                {
                    strColIdazi = mp_collParameters[COL_IDAZI].ToString();
                }

                if (Len(Trim(strColIdazi)) > 0)
                {
                    lIdAzi = GetIdAziFromDocument(strColIdazi, CStr(strDocKey), conn, trans);

                    //'--se il valore ritornato non  positivo esco
                    if (lIdAzi < 0)
                    {
                        strCause = $"recupero valore colonna = {strColIdazi} usata x i contatori = {lIdAzi} sul documento con IDDOC= {CStr(strDocKey)}";
                        throw new Exception($"{strCause} - FUNZIONE : {MODULE_NAME}.Elaborate");
                    }
                }

                strCause = "Chiamata a GetValCount";
                string v = GetValCount(conn, trans, ref strCause, strAlgoritmo, lIdPfu, lIdAzi, CLng(vIdMp));

                if (string.IsNullOrEmpty(v) || v == CStr('0'))
                    throw new Exception("Non è stato possibile recuperare o generare il protocollo. " + " - FUNZIONE : " + MODULE_NAME + ".GetCountersValue");

                //formatta il protocollo come anno a due cifre - numero su 6 chr
                if (mp_collParameters.ContainsKey(FORMAT))
                {
                    strFormat = mp_collParameters[FORMAT];
                }

                if (strFormat == "1")
                {
                    v = "00000000000000000000000000000000000000000000" + v;
                    vValues = MidVb6(DateTime.Now.Year.ToString(), 3, 2) + "-" + Right(v, LEN_NUMBER_PROTOCOL);
                }
                else
                    vValues = v;
            }
            catch (Exception ex)
            {
                throw new Exception($"{ex.Message} - {strCause} - FUNZIONE : {MODULE_NAME}.Elaborate", ex);
            }
        }

        private string GetValCount(SqlConnection conn, SqlTransaction trans, ref string strCause, string strAlgoritmo, long lIdPfu, long lIdAzi = -1, long lIdMP = -1)
        {
            string strReturn = string.Empty;
            bool bCentralized = false;

            if (lIdMP < 0)
            {
                throw new Exception("Il MP non è stato passato al metodo GetValCount - FUNZIONE : " + MODULE_NAME + ".GetValCount");
            }

            strCause = "se l'idazi non è passato in input lo recupera";

            var sqlParams = new Dictionary<string, object?>();
            sqlParams.Add("@IdPfu", lIdPfu);

            string strSql = "SELECT pfuIdAzi, pfuPrefissoProt FROM ProfiliUtente with (nolock) WHERE IdPfu = @IdPfu";
            TSRecordSet rsUtenti = cdf.GetRSReadFromQueryWithTransaction(strSql, conn.ConnectionString, conn, trans, iTimeout, sqlParams);
            if (lIdAzi == -1)
                lIdAzi = CInt(rsUtenti["pfuIdAzi"]!);
            string? strProt = CStr(rsUtenti["pfuPrefissoProt"]);

            strCause = "caso lIdDzt diverso da -1 Seleziona per gli attributi contatori il testo dello script e i valori iniziale e finale";

            sqlParams.Clear();
            sqlParams.Add("@Algoritmo", strAlgoritmo);

            strSql = "SELECT CNTIDDZT,IDCNT,CRSCRIPT,CNTSTARTVALUE,CNTENDVALUE FROM COUNTERS,COUNTERSRULES WHERE CNTIDCR=IDCR AND algoritmo = @Algoritmo AND cntDeleted=0 AND crDeleted=0";
            TSRecordSet rsCount = cdf.GetRSReadFromQueryWithTransaction(strSql, conn.ConnectionString, conn, trans, iTimeout, sqlParams);

            if (!(rsCount.EOF && rsCount.BOF))
            {
                strCause = "IsCounterCentralized - il contatore è ripartito o centralizzato";
                bCentralized = IsCounterCentralized(conn, trans, CInt(rsCount["IDCNT"]!), lIdMP);

                strCause = "GetValCount - se non è valorizzato eseguiamo lo script";
                strReturn = GetProtocolFromSP(conn, trans, rsCount, ref strCause, strAlgoritmo, strProt, lIdPfu, lIdAzi, lIdMP, bCentralized);
            }

            return strReturn;
        }

        private string GetProtocolFromSP(SqlConnection conn, SqlTransaction trans, TSRecordSet rsCount, ref string strCause, string strAlgoritmo, string strProt, long lIdPfu, long lIdAzi = -1, long lIdMP = -1, bool bCentralized = false)
        {
            string strSql = string.Empty;
            SqlConnection cnLocal = cdf.SetConnection(conn.ConnectionString);
            cnLocal.Open();

            int lIdCv = -1;
            int lIdCnt = CInt(rsCount["idcnt"]!);
            string? startvalue = CStr(rsCount["CNTSTARTVALUE"]);
            string? endvalue = CStr(rsCount["CNTENDVALUE"]);
            string? lastValue = string.Empty;
            string? valore = string.Empty;
            string strGUID = string.Empty;
            int nRet = 0;
            ClsSemaphore semaforo = new ClsSemaphore();

            //recupera l'ultimo valore se esiste

            try
            {

                strCause = "Inserisco il Semaforo per i CONTATORI";
                strGUID = semaforo.Init_Semaphore("CONTATORI", cnLocal.ConnectionString);

                //--recupero se specificato i field del documento utili ai contatori
                strCause = " EseguiScript - apertura recordset per recupero ultimo valore dalla tabella CountersValue ";

                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@IdCnt", lIdCnt);
                sqlParams.Add("@IdAzi", (bCentralized) ? -lIdMP : lIdAzi);

                strSql = "select * from CountersValue where cvidcnt=@IdCnt and cvIdAzi=@IdAzi";

                TSRecordSet rsCountersValue = new TSRecordSet();
                rsCountersValue = rsCountersValue.OpenWithTransaction(strSql, conn, trans, sqlParams, iTimeout);

                if (rsCountersValue.RecordCount > 0)
                {
                    lIdCv = CInt(rsCountersValue["idCv"]!);
                    lastValue = CStr(rsCountersValue["cvLastValue"]);
                }

                strCause = " EseguiScript - LastValueContatore recupero ultimo valore ";

                strCause = " EseguiScript - Eseguo script per calcolo nuovo valore";

                sqlParams.Clear();
                sqlParams.Add("@Algoritmo", strAlgoritmo);
                sqlParams.Add("@startvalue", startvalue);
                sqlParams.Add("@endvalue", endvalue);
                sqlParams.Add("@lastValue", lastValue);
                sqlParams.Add("@Prot", strProt);
                sqlParams.Add("@IdMP", lIdMP);
                sqlParams.Add("@IdAzi", lIdAzi);
                sqlParams.Add("@IdPfu", lIdPfu);
                strSql = "CTL_PROCESS_CLS_GET_PROTOCOL @Algoritmo, @startvalue, @endvalue, @lastValue, @Prot, @IdMP, @IdAzi, @IdPfu";

                TSRecordSet rs = cdf.GetRSReadFromQueryWithTransaction(strSql, conn.ConnectionString, conn, trans, iTimeout, sqlParams);

                if (!(rs.EOF && rs.BOF))
                {
                    rs.MoveFirst();
                    valore = CStr(rs[0]);
                }

                if (valore is not null)
                {
                    if (lIdCv != -1)
                    {
                        strCause = $" EseguiScript - aggiornamento record con ultimo valore contatore = {valore}";

                        UpdateRsCountersValue(valore, ref rsCountersValue);
                    }
                    else
                    {
                        if (bCentralized)
                        {
                            strCause = $" EseguiScript - Contatore Centralizzato non presente. Inserimento del primo valore = {valore} - lIdMP = {-lIdMP}";
                            InsertCountersvalue(-lIdMP, lIdCnt, valore, ref rsCountersValue);
                        }
                        else
                        {
                            strCause = $" EseguiScript - Contatore Non Centralizzato non presente. Inserimento del primo valore = {valore} - idazi = {lIdAzi}";
                            InsertCountersvalue(lIdAzi, lIdCnt, valore, ref rsCountersValue);
                        }
                    }
                }

                //--libero il mio semaforo dei CONTATORI
                strCause = "libero il Semaforo per i CONTATORI";
                if (Len(Trim(strGUID)) > 0)
                    nRet = semaforo.Drop_Semaphore("CONTATORI", strGUID, cnLocal.ConnectionString);
                semaforo.Dispose();

                return valore!;
            }
            catch (Exception ex)
            {
                try
                {
                    if (Len(Trim(strGUID)) > 0)
                        nRet = semaforo.Drop_Semaphore("CONTATORI", strGUID, cnLocal.ConnectionString);
                    semaforo.Dispose();
                }
                catch (Exception ex2)
                {
                    DebugTrace dt = new DebugTrace();
                    dt.Write("clsGetProtocol - Errore nella Drop_Semaphore : " + ex2.ToString());
                }

                throw new Exception($"FUNZIONE : {MODULE_NAME}.GetProtocolFromSP - {strCause} - {ex.Message}", ex);
            }
        }

        private void UpdateRsCountersValue(string valore, ref TSRecordSet rsCountersValue)
        {
            if (rsCountersValue is null)
            {
                throw new NullReferenceException("Metodo UpdateRsCountersValue. Il Recordset rsCountersValue non può essere null");
            }

            rsCountersValue.Fields["cvLastValue"] = valore;
            rsCountersValue.Update(rsCountersValue.Fields, "IdCv", "CountersValue");
        }

        private void InsertCountersvalue(long lIdAzi, long lIdCnt, string valore, ref TSRecordSet rsNewCountersValue)
        {
            DataRow dr = rsNewCountersValue.AddNew();
            dr["cvIdazi"] = lIdAzi;
            dr["cvIdcnt"] = lIdCnt;
            dr["cvlastValue"] = valore;
            rsNewCountersValue.Update(dr, "IdCv", "CountersValue");
        }

        private bool IsCounterCentralized(SqlConnection conn, SqlTransaction trans, long lIdCnt, long lIdMP)
        {
            bool bReturn = false;

            try
            {
                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@IdMP", lIdMP);
                sqlParams.Add("@IdCnt", lIdCnt);
                string strSql = "select * from MPCounters with (nolock) where mpcIdMp=@IdMP and mpcIdCnt=@IdCnt";
                TSRecordSet rsMPCounters = cdf.GetRSReadFromQueryWithTransaction(strSql, conn.ConnectionString, conn, trans, iTimeout, sqlParams);

                bReturn = !(rsMPCounters.EOF && rsMPCounters.BOF);
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message + " - FUNZIONE : " + MODULE_NAME + ".GetValCount", ex);
            }

            return bReturn;
        }

        //--recupero la colonna dell'azienda per i contarori dal documento
        private long GetIdAziFromDocument(string strCol, string strDocKey, SqlConnection conn, SqlTransaction trans)
        {
            long lReturn = -1;
            string strSql = string.Empty;

            try
            {
                strSql = $"select {strCol} from {mp_strTableName} where {mp_strFieldIDName} in ({strDocKey})";

                DbProfiler dbProfiler = new DbProfiler(ApplicationCommon.Configuration);
                dbProfiler.startProfiler();

                TSRecordSet rs = cdf.GetRSReadFromQueryWithTransaction(strSql, conn.ConnectionString, conn, trans, iTimeout);

                dbProfiler.endProfiler();
                dbProfiler.traceDbProfiler(strSql, ApplicationCommon.Application.ConnectionString); //conn.ConnectionString);

                if (!(rs.EOF && rs.BOF))
                {
                    rs.MoveFirst();
                    lReturn = CInt(rs[strCol]!);
                }
                return lReturn;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message + " - FUNZIONE : " + MODULE_NAME + ".GetIdAziFromDocument", ex);
            }
        }

    }
}
