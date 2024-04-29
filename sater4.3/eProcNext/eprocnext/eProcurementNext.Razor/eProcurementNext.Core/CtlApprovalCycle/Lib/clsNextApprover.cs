using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.CtlProcess;
using System.Data.SqlClient;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;
using static eProcurementNext.CtlProcess.Basic;

namespace eProcurementNext.CtlApprovalCycle
{
    internal class ClsNextApprover : ProcessBase
    {
        private const string MODULE_NAME = "CtlApprovalCycle.clsNextApprover";
        private readonly CommonDbFunctions cdf = new CommonDbFunctions();
        private Dictionary<string, string>? mp_collParameters = null;

        public override ELAB_RET_CODE Elaborate(string strDocType, dynamic strDocKey, long lIdPfu, string strParam, ref string strDescrRetCode, dynamic? vIdMp = null, dynamic? connection = null, SqlTransaction? transaction = null, int timeout = -1)
        {
            ELAB_RET_CODE strReturn = ELAB_RET_CODE.RET_CODE_ERROR;
            string strCause = string.Empty;

            try
            {
                SqlConnection? cnLocal = null;

                strDescrRetCode = string.Empty;

                // Apertura connessione
                strCause = "Apertura connessione al DB";

                cnLocal = SetConnection(connection, cdf);

                //''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                // STEP 1 --- legge i parametri necessari
                //''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                strCause = "Lettura dei parametri che determinano le azioni";
                bool bOK = GetParameters(strParam);

                if (!bOK)
                    return strReturn;

                //''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                // STEP 2 --- Esegue l'azione NextApprover sulla tabella CTL_ApprovalSteps
                //''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                strCause = "Esegue l'azione NextApprover sulla tabella CTL_ApprovalSteps";

                strReturn = NextApprovalSteps(cnLocal, transaction, strDocType, strDocKey, lIdPfu, ref strDescrRetCode);
                return strReturn;
            }
            catch (Exception ex)
            {
                throw new Exception($"{strCause} - {ex.Message} - FUNZIONE : {MODULE_NAME}.Elaborate", ex);
            }

            //    AFLErrorControl.StoreErrWithSource MODULE_NAME & " - " & strCause

            //    On Error Resume Next

            //    Set mp_collParameters = Nothing

            //    If Not(objctx Is Nothing) Then
            //        CloseConnection cnlocal
            //        objctx.SetAbort
            //    End If


            //    On Error GoTo 0
            //    AFLErrorControl.DecodeErr True
        }

        private bool GetParameters(string strParam)
        {
            bool bReturn = false;

            // I parametri vengono passati come Field1=Valore1&Field2=Valore2....
            try
            {
                mp_collParameters = GetCollectionExt(strParam);
            }
            catch (Exception ex)
            {
                DebugTrace dt = new DebugTrace();
                dt.Write(ex.ToString());
            }

            bReturn = true;
            return bReturn;
        }

        private ELAB_RET_CODE NextApprovalSteps(SqlConnection conn, SqlTransaction trans, string strDocType, dynamic strDocKey, long lIdPfu, ref string strDescrRetCode)
        {
            ELAB_RET_CODE strReturn = ELAB_RET_CODE.RET_CODE_ERROR;

            string strCause = string.Empty;

            try
            {

                //    SetRsRead rs, cnlocal

                strCause = "Cerca i record con stato=InCharge o stato=empty ordinati per ordine di inserimento";

                // cerca i record con stato=InCharge o stato=empty ordinati per ordine di inserimento
                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@DocType", strDocType);
                sqlParams.Add("@DocKey", CInt(strDocKey));

                string strSql = "select * from CTL_ApprovalSteps where APS_Doc_Type=@DocType and ";
                strSql += "APS_ID_DOC=@DocKey and (APS_State='InCharge' or APS_State='') and APS_IsOld=0 order by APS_ID_ROW";
                TSRecordSet rs = cdf.GetRSReadFromQueryWithTransaction(strSql, conn.ConnectionString, conn, trans, parCollection: sqlParams);

                if (rs.EOF && rs.BOF)
                {
                    strDescrRetCode = "Nessun utente trovato con stato InCharge";
                    return strReturn;
                }

                rs.MoveFirst();

                int lIdInCharge = -1;
                int lIdEmpty = -1;
                bool bExitLoop = false;

                // scorre il recordset cercando il primo record con stato InCharge
                // ed il primo ad esso successivo con stato=empty
                while (!rs.EOF && !bExitLoop)
                {
                    if (CStr(rs["APS_State"]) == "InCharge" && lIdInCharge == -1)
                        lIdInCharge = CInt(rs["APS_ID_ROW"]!);

                    if (CStr(rs["APS_State"]) == string.Empty && lIdInCharge > 0 && lIdEmpty == -1)
                    {
                        lIdEmpty = CInt(rs["APS_ID_ROW"]!);
                        bExitLoop = true;
                    }

                    rs.MoveNext();
                }

                //    CloseRecordset rs
                //    SetRsRead rs, cnlocal
                if (lIdInCharge == -1)
                {
                    strDescrRetCode = "Nessun utente trovato con stato InCharge";
                    return strReturn;
                }

                //--se devo ancora approvare controllo che al prossimo ruolo c' associato un utente per poter fare l'approvazione
                if (lIdEmpty > 0)
                {
                    strCause = "controllo che al prossimo ruolo c' associato un utente";
                    sqlParams.Clear();
                    sqlParams.Add("@IdEmpty", lIdEmpty);
                    strSql = "Select p1.idpfu,dbo.getcoddom2descml('UserRole',APS_UserProfile,'I') as Ruolo";
                    strSql = $"{strSql} from CTL_ApprovalSteps left outer join profiliutenteattrib  p2 on  p2.dztNome = 'UserRole' and  attValue = APS_UserProfile ";
                    strSql = $"{strSql} left outer join  profiliutente p1 on p1.idpfu = p2.idpfu And p1.pfuDeleted = 0 ";
                    strSql = $"{strSql} Where APS_ID_ROW = @IdEmpty";

                    rs = cdf.GetRSReadFromQueryWithTransaction(strSql, conn.ConnectionString, conn, trans, parCollection: sqlParams);

                    if (!(rs.EOF && rs.BOF))
                    {
                        rs.MoveFirst();
                        if (IsNull(CInt(rs["idpfu"]!)))
                        {
                            strDescrRetCode = $"Nessun utente associato al ruolo {CStr(rs["Ruolo"])}";
                            return strReturn;
                        }
                        else
                        {
                            strDescrRetCode = "Nessun utente associato al prossimo ruolo ";
                            return strReturn;
                        }
                    }
                }

                strCause = "Aggiornamento degli stati nella CTL_ApprovalSteps";

                sqlParams.Clear();
                sqlParams.Add("@lIdPfu", lIdPfu);
                sqlParams.Add("@lIdInCharge", lIdInCharge);

                // aggiorna il record InCharge mettendo stato=Approved e utente=utente input
                cdf.ExecuteWithTransaction("UPDATE CTL_ApprovalSteps SET APS_State='Approved',APS_IdPfu=@lIdPfu,APS_Date= getdate() where APS_ID_ROW=@lIdInCharge", conn.ConnectionString, conn, trans, parCollection: sqlParams);

                // aggiorna il record con stato=empty immediatamente successivo a quello InCharge mettendo stato=InCharge
                if (lIdEmpty > 0)
                {
                    sqlParams.Clear();
                    sqlParams.Add("@lIdEmpty", lIdEmpty);
                    cdf.ExecuteWithTransaction("UPDATE CTL_ApprovalSteps SET APS_State='InCharge' where APS_ID_ROW=@lIdEmpty", conn.ConnectionString, conn, trans, parCollection: sqlParams);
                }

                strReturn = ELAB_RET_CODE.RET_CODE_OK;
                return strReturn;
            }
            catch (Exception ex)
            {
                throw new Exception($"{ex.Message}-{strCause} - FUNZIONE : {MODULE_NAME}.Elaborate", ex);
            }
        }
    }
}
