using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using System.Data.SqlClient;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;
using static eProcurementNext.CtlProcess.Basic;

namespace eProcurementNext.CtlProcess
{
    internal class ClsMultiService : ProcessBase
    {
        private readonly CommonDbFunctions cdf = new CommonDbFunctions();
        private Dictionary<string, string>? mp_collParameters = null;

        private const string MODULE_NAME = "CtlProcess.ClsMultiService";

        //-------------------------------------------------------
        //-- PARAMETRI DA CONFIGURARE SULL'AZIONE DEL PROCESSO --
        //-------------------------------------------------------

        private const string REL_TYPE = "REL_TYPE";                              //-- Valore della colonna rel_type utilizzato nella where della select sulla ctl_relations per recuperare le invocazioni da fare
        private const string REL_VALUEINPUT = "REL_VALUEINPUT";     //-- Valore della colonna rel_valueInput utilizzato nella where della select sulla ctl_relations per recuperare le invocazioni da fare

        private const string TABLE = "TABLE";                                         //-- OPZ. Tabella (in scrittura verticale) da utilizzare per la gestione della stringa di bit sentinella per l'esito delle N invocazioni
        private const string DOC_KEY = "DOC_KEY";                              //-- OPZ. nome della colonna, relativa alla tabella passata nel parametro 'table', usata per caricarici il valore di strDocKey
        private const string DSE_ID = "DSE_ID";                                     //-- OPZ. valore della colonna 'DSE_ID' usata nella scrittura verticale della ctl_doc_value
        private int iTimeout = -1;

        public override ELAB_RET_CODE Elaborate(string strDocType, dynamic strDocKey, long lIdPfu, string strParam, ref string strDescrRetCode, dynamic? vIdMp = null, dynamic? connection = null, SqlTransaction? transaction = null, int timeout = -1)
        {
            ELAB_RET_CODE strReturn = ELAB_RET_CODE.RET_CODE_ERROR;
            string strCause = string.Empty;
            SqlConnection? cnLocal = null!;
            DebugTrace dt = new();
            iTimeout = timeout;

            try
            {
                string strSql = string.Empty;

                string relType = string.Empty;
                string relValInput = string.Empty;
                string relValOutput = string.Empty;
                string colDocKey = string.Empty;
                string dseID = string.Empty;
                string strTable = string.Empty;

                string strAvanzamento = string.Empty;
                int numeroServizio = 0;
                bool bOK = false;

                strDescrRetCode = string.Empty;

                strCause = "Lettura dei parametri che determinano le azioni";
                dt.Write("clsMultiService - Elaborate. Prima di GetParameters");
                if (GetParameters(strParam, ref strDescrRetCode))
                {
                    // Apertura connessione
                    strCause = "Apertura connessione al DB";

                    cnLocal = SetConnection(connection, cdf);
                    dt.Write("clsMultiService - Elaborate. Dopo SetConnection");
                    strCause = "Recupero i parametri dalla collezione";
                    relType = GetParamValue(REL_TYPE);
                    relValInput = GetParamValue(REL_VALUEINPUT);
                    colDocKey = GetParamValue(DOC_KEY);
                    strTable = GetParamValue(TABLE);
                    dseID = GetParamValue(DSE_ID);
                    dt.Write("clsMultiService - Elaborate. Dopo GetParamValue");
                    if (string.IsNullOrEmpty(strTable))
                    {
                        strTable = "v_protgen_dati";
                    }

                    dt.Write($"clsMultiService - Elaborate. strTable={strTable}, colDocKey={colDocKey}");
                    if (string.IsNullOrEmpty(colDocKey))
                    {
                        colDocKey = "idHeader";
                    }

                    dt.Write("clsMultiService - Elaborate. Prima di SetConnection objConn");
                    //        Set mp_objDB = CreateObject("ctldb.clsTabManage")
                    SqlConnection objConn = cdf.SetConnection(cnLocal.ConnectionString);

                    strCause = "Compongo la select per recuperare la stringa di avanzamento, se presente";
                    var sqlParams = new Dictionary<string, object?>
                    {
                        { "@DocKey", CLng(strDocKey) }
                    };
                    strSql = $"select Value from {strTable} with(nolock) where DZT_Name = 'avanzamentoServizi' and {colDocKey} = @DocKey";
                    if (!string.IsNullOrEmpty(dseID))
                    {
                        sqlParams.Add("@dseID", dseID);
                        strSql = $"{strSql} and DSE_ID = @dseID";
                    }

                    strCause = $"Eseguo {strSql}";
                    TSRecordSet? rs = cdf.GetRSReadFromQuery_(strSql, objConn.ConnectionString, objConn, iTimeout, sqlParams);

                    if (rs is not null && rs.RecordCount > 0)
                    {
                        rs.MoveFirst();
                        strAvanzamento = CStr(rs["Value"]);
                    }

                    //-- Nella select della CTL_Relations vado in like sulla colonna "REL_ValueInput" nella parte destra 'XXX%' e per sapere l'ordine di chiamata dei servizi facciamo una order su REL_ValueInput
                    sqlParams.Clear();
                    sqlParams.Add("@relType", relType);
                    sqlParams.Add("@relValInput", $"{relValInput}%");
                    strSql = "select REL_ValueOutput from CTL_Relations with(nolock) where REL_Type = @relType and REL_ValueInput like @relValInput order by REL_ValueInput";

                    strCause = $"Eseguo {strSql}";
                    rs = cdf.GetRSReadFromQuery_(strSql, objConn.ConnectionString, objConn, iTimeout, sqlParams);

                    if (rs is not null && rs.RecordCount > 0)
                    {
                        if (string.IsNullOrEmpty(strAvanzamento))
                        {
                            strAvanzamento = getStringaAvanzamento(rs.RecordCount);
                        }

                        rs.MoveFirst();
                        bOK = true;

                        while (!rs.EOF && bOK)
                        {
                            numeroServizio++;
                            dt.Write("clsMultiService - Elaborate. riga 113");
                            //-- Se il servizio ennesimo sul quale stiamo iterando non è stato ancora eseguito
                            if (MidVb6(strAvanzamento, numeroServizio, 1) == "0")
                            {
                                relValOutput = CStr(rs["REL_ValueOutput"]);

                                ClsInvokeService objProc = new ClsInvokeService();
                                ELAB_RET_CODE outputProcess;

                                try
                                {
                                    dt.Write("clsMultiService - Elaborate. riga 124");
                                    outputProcess = objProc.Elaborate(strDocType, strDocKey, lIdPfu, relValOutput, ref strDescrRetCode, vIdMp, connection, transaction);
                                }
                                catch
                                {
                                    outputProcess = ELAB_RET_CODE.RET_CODE_ERROR;
                                }

                                //                    Set objProc = Nothing
                                dt.Write("clsMultiService - Elaborate. riga 133");
                                // Se non  tutto OK per un servizio usciamo dal ciclo
                                bOK = (outputProcess == ELAB_RET_CODE.RET_CODE_OK);

                                //-- memorizzo l'esito dell'ennesimo servizio nella stringa di avanzamento
                                strAvanzamento = stuff(strAvanzamento, numeroServizio, bOK ? "1" : "0");

                                aggiornaSentinella(strAvanzamento, strDocKey, strTable, colDocKey, dseID, ref cnLocal, ref transaction);
                                dt.Write("clsMultiService - Elaborate. riga 141");
                            }

                            rs.MoveNext();
                        }
                    }

                    //-- tutto ok
                    strReturn = ELAB_RET_CODE.RET_CODE_OK;
                }
                dt.Write("clsMultiService - Elaborate. Dopo GetParameters");
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
            //    ' I parametri vengono passati come Field1=Valore1&Field2=Valore2....
            DebugTrace dt = new DebugTrace();
            try
            {
                mp_collParameters = GetCollectionExt(strParam);
                dt.Write("clsMultiService - GetParameters. riga 173");
                //    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                //    ' controlli sui parametri passati
                //    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                if (!mp_collParameters.ContainsKey(REL_TYPE))
                {
                    strDescrRetCode = "Manca il parametro input " + REL_TYPE;
                    return bReturn;
                }
                dt.Write("clsMultiService - GetParameters. riga 182");
                if (!mp_collParameters.ContainsKey(REL_VALUEINPUT))
                {
                    strDescrRetCode = "Manca il parametro input " + REL_VALUEINPUT;
                    return bReturn;
                }
                dt.Write("clsMultiService - GetParameters. riga 188");
                bReturn = true;
            }
            catch (Exception ex)
            {
                dt.Write("clsMultiService - GetParameters. " + ex.ToString());
                throw new Exception(ex.Message + " - FUNZIONE : " + MODULE_NAME + ".GetParameters", ex);
            }
            return bReturn;
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

        private string getStringaAvanzamento(int totServizi)
        {
            string strOut = String.Empty;

            for (int k = 1; k <= totServizi; k++)
            {
                strOut = $"{strOut}0";  
            }

            return strOut;
        }

        private string stuff(string original, int position, string newValue)
        {
            string s1 = string.Empty;
            string s2 = string.Empty;
            string strReturn = original;

            if (!string.IsNullOrEmpty(original) && position > 0 && position <= Len(original))
            {
                s1 = Left(original, position - 1);
                s2 = Right(original, Len(original) - position);

                strReturn = $"{s1}{newValue}{s2}";
            }

            return strReturn;
        }

        private void aggiornaSentinella(string sentinella, dynamic? strDocKey, string strTable, string colDocKey, string dseID, ref SqlConnection cnLocal, ref SqlTransaction trans)
        {
            var sqlParams = new Dictionary<string, object?>
            {
                { "@strDocKey", CLng(strDocKey) },
                { "@dseID", dseID }
            };

            string strSql = $"DELETE FROM {strTable} WHERE DZT_Name = 'avanzamentoServizi' and {colDocKey} = @strDocKey";
            if (!string.IsNullOrEmpty(dseID)) 
            {
                strSql = $"{strSql} and DSE_ID = @dseID";
            }

            cdf.ExecuteWithTransaction(strSql, cnLocal.ConnectionString, cnLocal, trans, iTimeout, sqlParams);

            sqlParams.Add("@sentinella", sentinella);

            strSql = $"INSERT INTO {strTable} ({colDocKey}, DZT_Name";
            if (!string.IsNullOrEmpty(dseID))
            {
                strSql = $"{strSql},DSE_ID";
            }
            strSql = $"{strSql},value) values (@strDocKey, 'avanzamentoServizi',";
            if (!string.IsNullOrEmpty(dseID))
            {
                strSql = $"{strSql}@dseID,";
            }
            strSql = $"{strSql}@sentinella)";

            cdf.ExecuteWithTransaction(CStr(strSql), cnLocal.ConnectionString, cnLocal, trans, iTimeout, sqlParams);
        }
    }
}
