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
    internal class ClsSetValue : ProcessBase
    {
        private readonly CommonDbFunctions cdf = new();
        private Dictionary<string, string>? mp_collParameters = null;
        long mp_lIdPfu = 0;

        private const string MODULE_NAME = "CtlProcess.ClsSetValue";
        //'-- parametri da configurare sull'azione del processo
        private const string QUERY_CONDITION = "QUERY_CONDITION"; //-- facoltativo, contiene la query che se non ritorna righe vuol dire che  falsa e non effettua i settaggi richiesti
        private const string QUERY_UPDATE = "QUERY_UPDATE"; //-- contiene la query per effettuare l'update richiesta
        //'-- alle due query viene sostituito il valore <ID_DOC> con l'identificativo del documento

        private int iTimeout = -1;

        public override ELAB_RET_CODE Elaborate(string strDocType, dynamic strDocKey, long lIdPfu, string strParam, ref string strDescrRetCode, dynamic? vIdMp = null, dynamic? connection = null, SqlTransaction? transaction = null, int timeout = -1)
        {
            ELAB_RET_CODE strReturn = ELAB_RET_CODE.RET_CODE_ERROR;
            string strCause = string.Empty;
            strDescrRetCode = string.Empty;
            mp_lIdPfu = lIdPfu;
            SqlConnection? cnLocal = null!;
            iTimeout = timeout;

            try
            {
                //    ' Apertura connessione
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
                        // STEP 3 --- Setta tutti i valori richiesti
                        strCause = "Setta tutti i valori richiesti";

                        SetValue(cnLocal, strDocKey, transaction);
                    }

                    strReturn = ELAB_RET_CODE.RET_CODE_OK;
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
                if (!mp_collParameters.ContainsKey(QUERY_UPDATE))
                {
                    strDescrRetCode = $"Manca il parametro input {QUERY_UPDATE}";
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

        private void SetValue(SqlConnection? conn, dynamic strDocKey, SqlTransaction trans)
        {
            string strSql = string.Empty;
            DebugTrace dt = new();
            try
            {
                strSql = mp_collParameters[QUERY_UPDATE];
                strSql = Replace(strSql, "<ID_USER>", CStr(mp_lIdPfu));
                strSql = Replace(strSql, "<ID_DOC>", CStr(strDocKey));

                if (GetParamValue("TIMEOUT") != string.Empty)
                    iTimeout = CInt(GetParamValue("TIMEOUT"));

                //DbProfiler dbProfiler = new DbProfiler(ApplicationCommon.Configuration);
                //dbProfiler.startProfiler();
                //dt.Write("clsSetValue strSql = " + GetSQLPrefixStatement() + strSql)
                cdf.ExecuteWithTransaction($"{GetSQLPrefixStatement()}{strSql}", conn!.ConnectionString, conn, trans, iTimeout);
                //dbProfiler.endProfiler();
               // dbProfiler.traceDbProfiler(strSql, conn.ConnectionString);
            }
            catch (Exception ex)
            {
                dt.Write("clsSetValue Errore = " + ex.ToString());
                throw new Exception($"{ex.Message} - FUNZIONE : {MODULE_NAME}.SetValue", ex);
            }
        }

        private bool CheckCondition(SqlConnection conn, SqlTransaction trans, dynamic strDocKey)
        {
            bool bReturn = false;
            string strSql = string.Empty;

            try
            {
                //-- controlla che sia stata configurata una condizione altrimenti esce
                try
                {
                    if (!mp_collParameters.ContainsKey(QUERY_CONDITION))
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

                strSql = mp_collParameters[QUERY_CONDITION];
                strSql = Replace(strSql, "<ID_USER>", CStr(mp_lIdPfu));
                strSql = Replace(strSql, "<ID_DOC>", CStr(strDocKey));

                if (GetParamValue("TIMEOUT") != string.Empty)
                {
                    iTimeout = CInt(GetParamValue("TIMEOUT"));
                }

                DbProfiler dbProfiler = new DbProfiler(ApplicationCommon.Configuration);
                dbProfiler.startProfiler();

                TSRecordSet rs = cdf.GetRSReadFromQueryWithTransaction($"{GetSQLPrefixStatement()}{strSql}", conn.ConnectionString, conn, trans, iTimeout);

                dbProfiler.endProfiler();
                dbProfiler.traceDbProfiler(strSql, ApplicationCommon.Application.ConnectionString); // conn.ConnectionString);

                bReturn = !(rs.EOF && rs.BOF);

                return bReturn;
            }
            catch (Exception ex)
            {
                throw new Exception($"{ex.Message} - FUNZIONE : {MODULE_NAME}.CheckCondition", ex);
            }
        }

        private string GetParamValue(dynamic strKey)
        {
            try
            {
                return mp_collParameters[strKey];
            }
            catch
            {
                return string.Empty;
            }
        }
    }
}
