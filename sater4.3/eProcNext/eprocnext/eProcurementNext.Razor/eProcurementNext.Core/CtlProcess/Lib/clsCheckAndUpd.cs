using eProcurementNext.Application;
using eProcurementNext.BizDB;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using System.Data.SqlClient;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;
using static eProcurementNext.CtlProcess.Basic;

namespace eProcurementNext.CtlProcess
{
    internal class ClsCheckAndUpd : ProcessBase
    {
        private readonly CommonDbFunctions cdf = new();
        private readonly DebugTrace dt = new DebugTrace();
        private Dictionary<string, string>? mp_collParameters = null!;
        long mp_lIdPfu = 0;

        private const string MODULE_NAME = "CtlProcess.ClsCheckAndUpd";

        //-- parametri da configurare sull'azione del processo
        private const string QUERY_CONDITION = "QUERY_CONDITION"; //--  contiene la query che se non ritorna righe vuol dire che  falsa e non effettua i settaggi richiesti
        private const string QUERY_UPDATE = "QUERY_UPDATE"; //-- Facoltativo, contiene la query per effettuare l'update richiesta se la condizione vera
        private const string UPDATE_OUT_TRANSACTION = "UPDATE_OUT_TRANSACTION"; //-- Facoltativo, se avvalorato con "yes" indica che la query di update  fuori della transazione
        private const string UPDATE_TRUE = "UPDATE_TRUE"; //-- Facoltativo, contiene yes se l'update fatto su condizione vera
        private const string UPDATE_FALSE = "UPDATE_FALSE"; //-- Facoltativo, contiene yes se l'update fatto su condizione falsa
                                                            //-- uno dei due deve essere presente altrimenti la condizione non viene eseguita
                                                            //-- se presenti entrambi l'update viene eseguito sempre
        private const string NOT_CONDITION = "NOT_CONDITION"; //-- inverte la condizione se il suo valore  "yes"
        private const string Msg = "MSG"; //-- Messaggio in ML da restituire se la condizione  falsa
        private const string BREAKANDCOMMITTT = "BREAK_AND_COMMITTT"; //Facoltativo; indica se fermarsi e fare il commit
        //-- alle due query viene sostituito il valore <ID_DOC> con l'identificativo del documento
        private int iTimeout = -1;

        public override ELAB_RET_CODE Elaborate(string strDocType, dynamic strDocKey, long lIdPfu, string strParam, ref string strDescrRetCode, dynamic? vIdMp = null, dynamic? connection = null, SqlTransaction? transaction = null, int timeout = -1)
        {
            string strCause = string.Empty;
            SqlConnection? cnLocal = null!;
            iTimeout = timeout;

            try
            {
                ELAB_RET_CODE strReturn = ELAB_RET_CODE.RET_CODE_ERROR;

                strDescrRetCode = string.Empty;
                mp_lIdPfu = lIdPfu;

                //Apertura connessione
                strCause = "Apertura connessione al DB";

                cnLocal = SetConnection(connection, cdf);

                // STEP 1 --- legge i parametri necessari
                strCause = "Lettura dei parametri che determinano le azioni";

                if (GetParameters(strParam, ref strDescrRetCode))
                {
                    // STEP 2 --- Controllo della condizione per eseguire l' update dei valori richiesti
                    strCause = "Controllo della condizione per eseguire l' update dei valori richiesti";

                    if (CheckCondition(cnLocal, transaction, strDocKey))
                    {
                        //-- se deve eseguire l'update per condizione vera
                        if (UCase(GetParamValue(UPDATE_TRUE)) == "YES")
                        {
                            // STEP 3 --- Setta tutti i valori richiesti
                            strCause = "Setta tutti i valori richiesti";

                            if (SetValue(cnLocal, strDocKey, transaction))
                                strReturn = ELAB_RET_CODE.RET_CODE_OK;
                        }
                        else
                            strReturn = ELAB_RET_CODE.RET_CODE_OK;
                    }
                    else
                    {
                        //-- ritorno la descrittiva configurata
                        strDescrRetCode = GetParamValue(Msg);

                        //-- se deve eseguire l'update per condizione falsa
                        if (UCase(GetParamValue(UPDATE_FALSE)) == "YES")
                        {
                            // STEP 3 --- Setta tutti i valori richiesti
                            strCause = "Setta tutti i valori richiesti per false";

                            SetValue(cnLocal, strDocKey, transaction);
                        }

                        //--controllo se devo fare lo stesso il commit
                        if (UCase(GetParamValue(BREAKANDCOMMITTT)) == "YES")
                            strReturn = ELAB_RET_CODE.RET_CODE_BREAKANDCOMMIT;
                    }
                }
                return strReturn;
            }
            catch (Exception ex)
            {
                CommonDB.Basic.TraceErr(ex, cnLocal.ConnectionString, MODULE_NAME);
                throw new Exception($"{strCause} - {ex.Message} - FUNZIONE : {MODULE_NAME}.Elaborate", ex);
            }
        }

        private bool GetParameters(string strParam, ref string strDescrRetCode)
        {
            bool bReturn = false;

            // I parametri vengono passati come Field1=Valore1&Field2=Valore2....
            try
            {
                mp_collParameters = GetCollectionExt(strParam);

                //    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                //    ' controlli sui parametri passati
                //    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                if (!mp_collParameters.ContainsKey(QUERY_CONDITION))
                {
                    strDescrRetCode = $"Manca il parametro input {QUERY_CONDITION}";
                    return bReturn;
                }

                if (!mp_collParameters.ContainsKey(Msg))
                {
                    strDescrRetCode = $"Manca il parametro input {Msg}";
                    return bReturn;
                }

                bReturn = true;
                return bReturn;
            }
            catch (Exception ex)
            {
                dt.Write("clsCheckAndUpd - GetParameters");
                throw new Exception($"{ex.Message} - FUNZIONE : {MODULE_NAME}.GetParameters", ex);
            }
        }

        private bool SetValue(SqlConnection conn, dynamic strDocKey, SqlTransaction trans)
        {
            bool bReturn = false;
            string strSql = string.Empty;

            try
            {
                strSql = (mp_collParameters![QUERY_UPDATE].Replace("<ID_USER>", CStr(mp_lIdPfu))).Replace("<ID_DOC>", strDocKey.ToString());

                if (UCase(GetParamValue(UPDATE_OUT_TRANSACTION)) == "YES")
                {
                    CommonDbFunctions tempcdf = new();
                    using SqlConnection tmpConn = new(conn.ConnectionString);
                    tmpConn.Open();
                    tempcdf.Execute($"{GetSQLPrefixStatement()}{strSql}", tmpConn.ConnectionString, tmpConn);
                }
                else
                {
                    if (GetParamValue("TIMEOUT") != string.Empty)
                        iTimeout = CInt(GetParamValue("TIMEOUT"));

                    DbProfiler dbProfiler = new(ApplicationCommon.Configuration);
                    dbProfiler.startProfiler();

                    cdf.ExecuteWithTransaction($"{GetSQLPrefixStatement()}{strSql}", conn.ConnectionString, conn, trans, iTimeout);

                    dbProfiler.endProfiler();
                    dbProfiler.traceDbProfiler(strSql, ApplicationCommon.Application.ConnectionString); // conn.ConnectionString);
                }
                bReturn = true;
            }
            catch (Exception ex)
            {
                dt.Write("clsCheckAndUpd - SetValue");
                throw new Exception($"{ex.Message} - FUNZIONE : {MODULE_NAME}.SetValue", ex);
            }
            return bReturn;
        }

        private bool CheckCondition(SqlConnection conn, SqlTransaction trans, dynamic strDocKey)
        {
            bool bReturn = false;
            string strSql = string.Empty;

            try
            {
                try
                {
                    if (!mp_collParameters!.ContainsKey(QUERY_CONDITION))
                    {
                        bReturn = true;
                        return bReturn;
                    }
                }
                catch
                {
                    bReturn = true;
                    return bReturn;
                }

                strSql = (mp_collParameters[QUERY_CONDITION].Replace("<ID_USER>", CStr(mp_lIdPfu))).Replace("<ID_DOC>", CStr(strDocKey));

                if (GetParamValue("TIMEOUT") != string.Empty)
                    iTimeout = CInt(GetParamValue("TIMEOUT"));

                DbProfiler dbProfiler = new(ApplicationCommon.Configuration);
                dbProfiler.startProfiler();

                TSRecordSet rs = cdf.GetRSReadFromQueryWithTransaction($"{GetSQLPrefixStatement()}{strSql}", conn.ConnectionString, conn, trans, iTimeout);

                dbProfiler.endProfiler();
                dbProfiler.traceDbProfiler(strSql, ApplicationCommon.Application.ConnectionString); // conn.ConnectionString);

                bReturn = !(rs.EOF && rs.BOF);

                if (mp_collParameters.ContainsKey(NOT_CONDITION) && (UCase(Trim(mp_collParameters[NOT_CONDITION])) == "YES"))
                {
                    bReturn = !bReturn;
                }

                return bReturn;
            }
            catch (Exception ex)
            {
                dt.Write("clsCheckAndUpd - CheckCondition");
                throw new Exception($"{ex.Message} - FUNZIONE : {MODULE_NAME}.CheckCondition", ex);
            }
        }

        private string GetParamValue(dynamic strKey)
        {
            try
            {
                return mp_collParameters![strKey];
            }
            catch (Exception)
            {
                return string.Empty;
            }
        }
    }
}
