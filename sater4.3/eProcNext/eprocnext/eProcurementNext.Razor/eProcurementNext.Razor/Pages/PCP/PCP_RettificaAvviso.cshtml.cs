using eProcurementNext.Application;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data;
using System.Data.SqlClient;
using static eProcurementNext.CommonModule.Basic;
using Basic = eProcurementNext.CommonDB.Basic;
using eProcurementNext.DashBoard;
using eProcurementNext.CommonDB;
using static eProcurementNext.Razor.Pages.PCP.PCP_ConfermaAppalto;
using eProcurementNext.CtlProcess;
using static eProcurementNext.CommonModule.Const;

namespace eProcurementNext.Razor.Pages.PCP
{
    public class PCP_RettificaAvviso : PageModel
    {
        public string? rettifica_avviso(int idRow)
        {
            string res = string.Empty;

            try
            {
                UpdateServiceIntegration(idRow, "InGestione");

                DatiRettificaAvviso dtRet = recuperaDati(idRow);

                switch (dtRet.tipoScheda)
                {
                    //Richiediamo il change notice solo per le schede che prevedono un eForm
                    case "P1_16":
                    case "P1_19":
                    case "P1_20":
                        XMLChangeNotice(dtRet.idDoc, dtRet.idGara, -20, true);
                        break;
                }

                var urlToInvoke = $@"{ApplicationCommon.Application["WEBSERVERAPPLICAZIONE_INTERNO"]}/WebApiFramework/api/ConfermaAppalto/rettificaAvviso?idRow={idRow}&idGara={dtRet.idGara}&idDoc={dtRet.idDoc}";

                res = invokeUrl(urlToInvoke);
            }
            catch (Exception ex)
            {

                //Senza questo update la sentinella resta "bloccata" nello stato di "InGestione"
                UpdateServiceIntegration(idRow, "Errore", ex.ToString());

                //Se l'eccezione è nel formato standard restituito dalla invokeUrl, prendo solo il messaggio di errore
                if (ex.Message.IndexOf("Output: ") != -1)
                {
                    res = ex.Message[(ex.Message.IndexOf("Output: ") + "Output: ".Length)..];
                    if (!res.StartsWith("0#"))
                    {
                        res = $"0#{res}";
                    }
                }
                else
                {
                    res = $"0#{ex.Message}";
                }
            }
            finally
            {
                if (res.StartsWith("0#"))
                    Basic.LogEvent(Basic.TsEventLogEntryType.Error, res, ApplicationCommon.Application["ConnectionString"], "PCP_RettificaAvviso");
            }


            if (res.StartsWith("0#") || res.StartsWith("1#"))
            {
                return res;
            }
            else if (!res.StartsWith("1#"))
            {
                return $"1#{res}";
            }
            else
            {
                return res;
            }
        }

        public void UpdateServiceIntegration(int idRow, string stato, string msgError = "")
        {
            CommonDB.CommonDbFunctions cdf = new();
            var sqlParams = new Dictionary<string, object?>();

            sqlParams.Add("@idRow", idRow);
            sqlParams.Add("@dataExecuted", DateTime.Now);
            sqlParams.Add("@statoRichiesta", stato);

            string strSQL = "UPDATE Services_Integration_Request set StatoRichiesta = @statoRichiesta, DataExecuted = @dataExecuted ";

            if (!string.IsNullOrEmpty(msgError))
            {
                strSQL += ", MsgError = @msgError";
                sqlParams.Add("@msgError", msgError);
            }

            strSQL += " where IdRow = @idRow";

            cdf.Execute(strSQL, ApplicationCommon.Application["ConnectionString"], parCollection: sqlParams);

        }
        private class DatiRettificaAvviso
        {
            public int idGara
            {
                get;
                set;
            }
            public int idDoc
            {
                get; set;
            }
            public string tipoScheda
            {
                get; set;
            }
        }

        private DatiRettificaAvviso recuperaDati(int idRow)
        {
            string iddoc = string.Empty;
            SqlCommand cmd = new SqlCommand();
            string strConn = ApplicationCommon.Application.ConnectionString;
            SqlConnection conn = new SqlConnection(strConn);
            cmd.Connection = conn;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idRow", idRow);

            string strSql = @"select idRichiesta as idDoc,
		                            b.LinkedDoc as idGara,
		                            c.pcp_TipoScheda as tipoSheda
	                            from Services_Integration_Request a with(nolock) 
				                            inner join ctl_doc b with(Nolock) on b.Id = a.idRichiesta
				                            inner join Document_PCP_Appalto c with(nolock) on c.idHeader = b.LinkedDoc
	                            where a.idRow = @idRow";
            cmd.CommandType = CommandType.Text;
            cmd.CommandText = strSql;

            conn.Open();

            DatiRettificaAvviso dtRet = new();

            try
            {
                using var rs = cmd.ExecuteReader();

                if (rs.Read())
                {
                    dtRet.idGara = (int)rs["idGara"];
                    dtRet.idDoc = (int)rs["idDoc"];
                    dtRet.tipoScheda = (string)rs["tipoSheda"];
                }
                else
                {
                    throw new ApplicationException("Dati collegati alla rettifica non trovati");
                }


            }
            finally
            {
                conn.Close();
            }

            return dtRet;
        }

        /// <summary>
        /// Metodo per invocare il processo di generazione dell'xml di Change Notice. Andrà invocato solo per la rettifica di quelle schede che prevedono l'eForm
        /// </summary>
        /// <param name="iddoc">L'id del documento che innesca la modifica ( rettifica, proroga, etc )</param>
        /// <param name="idpfu"></param>
        /// <param name="obblig">Per lanciare errore se l'xml di change notice non viene restituito</param>
        /// <returns></returns>
        /// <exception cref="Exception"></exception>
        public string XMLChangeNotice(int iddoc, int idGara, int idpfu, bool obblig)
        {
            string strToReturn = "";
            string msgTitle = "";
            int msgIcon = 0;
            string msgError = "";
            //DashBoardMod.ExecuteProcess(new Session.Session(), "RETTIFICA_GARA", "XML_CHANGE_NOTICE", iddoc, idpfu, ref msgTitle, ref msgIcon, ref msgBody, ApplicationCommon.Application.ConnectionString);

            var obj_el = new ClsElab();
            ELAB_RET_CODE vRetCode = obj_el.Elaborate("XML_CHANGE_NOTICE", "RETTIFICA_GARA", iddoc, idpfu, ref msgError, 1, ApplicationCommon.Application.ConnectionString);

            if (vRetCode != ELAB_RET_CODE.RET_CODE_OK)
            {
                if (obblig)
                {
                    throw new Exception(msgError);
                }
            }

            try
            {
                var cdf = new CommonDbFunctions();

                Dictionary<string, object> pSql = new() { { "@iddoc", idGara } };

                TSRecordSet rsTEMPLATE_CONTEST = cdf.GetRSReadFromQuery_("select top 1 payload from Document_E_FORM_PAYLOADS with(nolock) where idheader = @iddoc and operationType = 'CN16_CHANGE_NOTICE' order by idRow desc"
                    , ApplicationCommon.Application.ConnectionString, pSql!)!;

                if(rsTEMPLATE_CONTEST.RecordCount > 0)
                {
                    strToReturn = CStr(rsTEMPLATE_CONTEST["payload"]);
                }
                

                if (obblig && string.IsNullOrEmpty(strToReturn))
                {
                    throw new Exception("Errore xml ChangeNotice vuoto");
                }

            }
            catch (Exception ex)
            {
                if (obblig)
                {
                    throw new Exception($"Errore caricamento xml ChangeNotice : {ex.Message}");
                }
            }

            new PCP_ConfermaAppalto().inserisciLogIntegrazione(iddoc, "genera-xml-eform", "Elaborato", "ChangeNotice", "", strToReturn, strToReturn, DateTime.Now, DateTime.Now, DateTime.Now, idpfu, -20, "OUT");
            return strToReturn;
        }

    }
}
