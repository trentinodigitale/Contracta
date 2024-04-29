using eProcurementNext.CommonDB;
using System.Data;
using System.Data.SqlClient;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;
using static eProcurementNext.CtlProcess.Basic;

namespace eProcurementNext.CtlProcess
{
    internal class ClsCanSend : ProcessBase
    {
        private readonly CommonDbFunctions cdf = new CommonDbFunctions();
        private Dictionary<string, string>? mp_collParameters = null!;

        private const string MODULE_NAME = "CtlProcess.ClsCanSend";

        private const string QUERY_SELECT_ROWS_INVALID = "QUERY_SELECT_ROWS_INVALID";
        private const string QUERY_CHECK_DOC = "QUERY_CHECK_DOC";
        private const string QUERY_CHECK_ROWS = "QUERY_CHECK_ROWS";

        private int iTimeout = -1;

        //QUERY_SELECT_ROWS_INVALID#=#SELECT * FROM RDA_CANSEND WHERE ID_DOC=<ID_DOC>

        public override ELAB_RET_CODE Elaborate(string strDocType, dynamic strDocKey, long lIdPfu, string strParam, ref string strDescrRetCode, dynamic? vIdMp = null, dynamic? connection = null, SqlTransaction? transaction = null, int timeout = -1)
        {
            ELAB_RET_CODE strReturn = ELAB_RET_CODE.RET_CODE_ERROR;
            SqlConnection? cnLocal = null!;
            iTimeout = timeout;

            string strCause = string.Empty;
            try
            {
                strDescrRetCode = string.Empty;

                // Apertura connessione
                strCause = "Apertura connessione al DB";

                cnLocal = SetConnection(connection, cdf);

                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                // STEP 1 --- legge i parametri necessari
                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                strCause = "Lettura dei parametri che determinano le azioni";
                bool bOK = GetParameters(strParam, ref strDescrRetCode);

                if (!bOK)
                {
                    return strReturn;
                }

                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                // STEP 2 --- Controllo esistenza documento e righe se previsto dalla configurazione
                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                strCause = "Controllo esistenza documento e righe se previsto dalla configurazione";

                if (!CheckExist(cnLocal, transaction, strDocKey, ref strDescrRetCode))
                {
                    return strReturn;
                }

                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                //  STEP 3 --- Controllo delle righe invalide
                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                strCause = "Esegue il controllo dei campi obbligatori";

                if (!CheckObblig(cnLocal, transaction, strDocKey, ref strDescrRetCode))
                {
                    return strReturn;
                }

                strReturn = ELAB_RET_CODE.RET_CODE_OK;
            }
            catch (Exception ex)
            {
                CommonDB.Basic.TraceErr(ex, cnLocal.ConnectionString, MODULE_NAME);
                throw new Exception($"{strCause} - {ex.Message} - FUNZIONE : {MODULE_NAME}.Elaborate", ex);
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

                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                // controlli sui parametri passati
                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

                // query di selezione righe invalide
                if (!mp_collParameters.ContainsKey(QUERY_SELECT_ROWS_INVALID))
                {
                    strDescrRetCode = $"Manca il parametro input {QUERY_SELECT_ROWS_INVALID}";
                    return bReturn;
                }

                bReturn = true;
                return bReturn;
            }
            catch (Exception ex)
            {
                throw new Exception($"{ex.Message} - FUNZIONE : {MODULE_NAME}.GetParameters", ex);
            }
        }

        private bool CheckExist(SqlConnection conn, SqlTransaction trans, dynamic? strDocKey, ref string strDescrRetCode)
        {
            bool bReturn = true;
            try
            {
                string s = string.Empty;

                // controllo eventuale esistenza documento
                if (!mp_collParameters!.ContainsKey(QUERY_CHECK_DOC))
                {
                    strDescrRetCode = $"Manca il parametro input {QUERY_CHECK_DOC}";
                    return bReturn;
                }

                s = mp_collParameters[QUERY_CHECK_DOC];

                if (Len(Trim(s)) > 0)
                {
                    TSRecordSet rs = cdf.GetRSReadFromQueryWithTransaction(Replace(mp_collParameters[QUERY_CHECK_DOC], "<ID_DOC>", CStr(strDocKey)), conn.ConnectionString, conn, trans, iTimeout);

                    if (rs.EOF && rs.BOF)
                    {
                        bReturn = false;
                        strDescrRetCode = "Documento non trovato nel DB";
                        return bReturn;
                    }
                }

                // controllo eventuale esistenza righe di prodotto
                if (!mp_collParameters.ContainsKey(QUERY_CHECK_ROWS))
                {
                    strDescrRetCode = $"Manca il parametro input {QUERY_CHECK_ROWS}";
                    return bReturn;
                }
                if (Len(Trim(s)) > 0)
                {
                    TSRecordSet rs = cdf.GetRSReadFromQueryWithTransaction(Replace(mp_collParameters[QUERY_CHECK_ROWS], "<ID_DOC>", CStr(strDocKey)), conn.ConnectionString, conn, trans, iTimeout);

                    if (rs.EOF && rs.BOF)
                    {
                        bReturn = false;
                        strDescrRetCode = "Il Documento deve contenere almeno una riga di prodotto";
                        return bReturn;
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"{ex.Message} - FUNZIONE : {MODULE_NAME}.CheckExist", ex);
            }

            return bReturn;
        }

        bool CheckObblig(SqlConnection conn, SqlTransaction trans, dynamic? strDocKey, ref string strDescrRetCode)
        {
            bool bReturn = false;

            try
            {
                TSRecordSet rs = cdf.GetRSReadFromQueryWithTransaction(Replace(mp_collParameters![QUERY_SELECT_ROWS_INVALID], "<ID_DOC>", CStr(strDocKey)), conn.ConnectionString, conn, trans, iTimeout);

                if (rs.EOF && rs.BOF)
                    bReturn = true;
                else
                {
                    // se il recordset  non vuoto contiene le righe con almeno un campo
                    // obbligatorio vuoto o NULL
                    // cerca la prima riga con il primo campo obblig. non avvalorato
                    dynamic v;

                    strDescrRetCode = "I seguenti campi obbligatori non sono avvalorati: ";

                    rs.MoveFirst();
                    Dictionary<string, string> collApp = new Dictionary<string, string>();

                    while (!rs.EOF)
                    {
                        foreach (DataColumn dc in rs.Columns!)
                        {
                            v = rs.Fields[dc];
                            if (v == null || v.ToString() == string.Empty && !collApp.ContainsKey(dc.ColumnName))
                            {
                                collApp.Add(dc.ColumnName, dc.ColumnName);
                                // usiamo il carattere di split per il multilinguismo
                                strDescrRetCode = $"{strDescrRetCode}#@#{dc.ColumnName},";
                            }
                        }
                        rs.MoveNext();
                    }

                    bReturn = false;
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"{ex.Message} - FUNZIONE : {MODULE_NAME}.CheckObblig", ex);
            }
            return bReturn;
        }
    }
}
