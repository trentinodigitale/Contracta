using eProcurementNext.CommonDB;
using eProcurementNext.CtlProcess;
using System.Data.SqlClient;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;
using static eProcurementNext.CtlProcess.Basic;

namespace eProcurementNext.CtlApprovalCycle
{
    internal class ClsNotApprove : ProcessBase
    {
        private const string MODULE_NAME = "CtlApprovalCycle.clsNotApprove";
        private readonly CommonDbFunctions cdf = new CommonDbFunctions();
        private Dictionary<string, string>? mp_collParameters = null;

        private const string QUERY_UPDATE_STATUS_DOC = "QUERY_UPDATE_STATUS_DOC";

        public override ELAB_RET_CODE Elaborate(string strDocType, dynamic strDocKey, long lIdPfu, string strParam, ref string strDescrRetCode, dynamic? vIdMp = null, dynamic? connection = null, SqlTransaction? transaction = null, int timeout = -1)
        {
            ELAB_RET_CODE strReturn = ELAB_RET_CODE.RET_CODE_ERROR;

            string strCause = string.Empty;
            SqlConnection? cnLocal = null;

            try
            {
                strDescrRetCode = string.Empty;

                // Apertura connessione
                strCause = "Apertura connessione al DB";

                cnLocal = SetConnection(connection, cdf);

                //''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                // STEP 1 --- legge i parametri necessari
                //''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                strCause = "Lettura dei parametri che determinano le azioni";
                bool bOK = GetParameters(strParam, ref strDescrRetCode);

                if (!bOK)
                    return strReturn;

                //''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                // STEP 2 --- Esegue l'azione NextApprover sulla tabella CTL_ApprovalSteps
                //''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                strCause = "Esegue l'azione NotApprove sulla tabella CTL_ApprovalSteps";

                strReturn = NotApprovalSteps(cnLocal, transaction, strDocType, strDocKey, lIdPfu);

                //''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                // STEP 3 --- Cambia lo stato del documento a Denied
                //''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                if (strReturn == ELAB_RET_CODE.RET_CODE_OK)
                {
                    strCause = "Cambia lo stato del documento a Denied";
                    string strUpdate = mp_collParameters![QUERY_UPDATE_STATUS_DOC].ToString();

                    strUpdate = Replace(strUpdate, "<VALUE_STATUS>", "NotApproved");
                    strUpdate = Replace(strUpdate, "<ID_DOC>", CStr(strDocKey));

                    cdf.ExecuteWithTransaction(strUpdate, cnLocal.ConnectionString, cnLocal, transaction);
                }

                return strReturn;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message + " - FUNZIONE : " + MODULE_NAME + ".Elaborate", ex);
            }

            //    On Error Resume Next

            //    Set mp_collParameters = Nothing

            //    If Not(objctx Is Nothing) Then
            //        CloseConnection cnlocal
            //        objctx.SetAbort
            //    End If


            //    On Error GoTo 0
            //    AFLErrorControl.DecodeErr True
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
                if (!mp_collParameters.ContainsKey(QUERY_UPDATE_STATUS_DOC))
                {
                    strDescrRetCode = $"Manca il parametro input {QUERY_UPDATE_STATUS_DOC}";
                    return bReturn;
                }

                bReturn = true;
                return bReturn;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message + " - FUNZIONE : " + MODULE_NAME + ".GetParameters", ex);
            }
        }

        private ELAB_RET_CODE NotApprovalSteps(SqlConnection conn, SqlTransaction trans, string strDocType, dynamic strDocKey, long lIdPfu)
        {
            ELAB_RET_CODE strReturn = ELAB_RET_CODE.RET_CODE_ERROR;

            string strCause = string.Empty;

            try
            {
                strCause = "Aggiorna i record con stato=InCharge a NotApprove, cambiando anche utente e data";

                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@IdPfu", lIdPfu);
                sqlParams.Add("@DocType", strDocType);
                sqlParams.Add("@DocKey", CStr(strDocKey));

                string strQuery = "UPDATE CTL_ApprovalSteps SET APS_State='Denied',APS_IdPfu=@IdPfu,APS_Date=getdate()";
                strQuery = $"{strQuery} where APS_Doc_Type=@DocType and APS_ID_DOC=@DocKey";
                strQuery = $"{strQuery} and APS_State='InCharge' and APS_IsOld=0";
                cdf.ExecuteWithTransaction(strQuery, conn.ConnectionString, conn, trans, parCollection: sqlParams);

                strReturn = ELAB_RET_CODE.RET_CODE_OK;
                return strReturn;
            }
            catch (Exception ex)
            {
                throw new Exception($"{ex.Message} {strCause} - FUNZIONE : {MODULE_NAME}.Elaborate", ex);
            }
        }

    }
}
