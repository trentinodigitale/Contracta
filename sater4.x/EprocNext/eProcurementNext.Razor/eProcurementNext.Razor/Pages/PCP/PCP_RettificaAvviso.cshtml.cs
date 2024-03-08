using eProcurementNext.Application;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data;
using System.Data.SqlClient;
using static eProcurementNext.CommonModule.Basic;
using Basic = eProcurementNext.CommonDB.Basic;
using eProcurementNext.DashBoard;
using eProcurementNext.CommonDB;

namespace eProcurementNext.Razor.Pages.PCP
{
    public class PCP_RettificaAvviso : PageModel
    {
        public string? rettifica_avviso(int idRow)
        {
            string res = string.Empty;

            try
            {

                string urlToInvoke = $@"/WebApiFramework/api/ConfermaAppalto/rettificaAvviso?idRow={idRow}";


                if (!Uri.IsWellFormedUriString(urlToInvoke, UriKind.Absolute))
                {
                    urlToInvoke = ApplicationCommon.Application["WEBSERVERAPPLICAZIONE_INTERNO"] + urlToInvoke;
                }

                res = invokeUrl(urlToInvoke);
            }
            catch (Exception ex)
            {
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

        public string recuperaIdDoc(int idRow)
        {
            string iddoc = string.Empty;
            SqlCommand cmd = new SqlCommand();
            string strConn = ApplicationCommon.Application.ConnectionString;
            SqlConnection conn = new SqlConnection(strConn);
            cmd.Connection = conn;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idRow", idRow);


            string strSql = "select idRichiesta from Services_Integration_Request with(nolock) where idRow = @idRow";
            cmd.CommandType = CommandType.Text;
            cmd.CommandText = strSql;

            conn.Open();
            object codice = cmd.ExecuteScalar();
            if (codice != null)
            {
                iddoc = codice.ToString();
            }
            conn.Close();

            return iddoc;
        }

        /// <summary>
        /// Metodo per invocare il processo di generazione dell'xml di Change Notice. Andrà invocato solo per la rettifica di quelle schede che prevedono l'eForm
        /// </summary>
        /// <param name="iddoc">L'id del documento che innesca la modifica ( rettifica, proroga, etc )</param>
        /// <param name="idpfu"></param>
        /// <param name="obblig"></param>
        /// <returns></returns>
        /// <exception cref="Exception"></exception>
        public string XMLChangeNotice(int iddoc, int idpfu, bool obblig)
        {
            string strToReturn = "";
            string msgTitle = "";
            int msgIcon = 0;
            string msgBody = "";
            DashBoardMod.ExecuteProcess(new Session.Session(), "RETTIFICA_GARA", "XML_CHANGE_NOTICE", iddoc, idpfu, ref msgTitle, ref msgIcon, ref msgBody, ApplicationCommon.Application.ConnectionString);

            //TODO: Cambiare il modo di testare l'errore. non va bene basarsi sul msgBody, si deve gestire l'errore o lo status di risposta
            if (msgIcon != MSG_INFO && msgBody != "???XML_CHANGE_NOTICE??? eseguito correttamente")
            {
                if (obblig)
                {
                    throw new Exception(msgBody);
                }
            }

            try
            {
                //TODO: Cambiato l'operationType rispetto all'eForm utilizzato sull'appalto. gestire questo tipo anche nel controller lato api
                var cdf = new CommonDbFunctions();
                TSRecordSet rsTEMPLATE_CONTEST = cdf.GetRSReadFromQuery_(
                    "select top 1 payload from Document_E_FORM_PAYLOADS with(nolock) where idheader = " + iddoc + " and operationType = 'CN16_CHANGE_NOTICE' order by idRow desc"
                    , ApplicationCommon.Application.ConnectionString)!;
                strToReturn = CStr(rsTEMPLATE_CONTEST["payload"]);
            }
            catch
            {
                if (obblig)
                {
                    throw new Exception("Errore caricamento xml ChangeNotice");
                }
            }
           
            //TODO: lasciamo la traccia così o ne inseriamo una specifica per il change notice ?
            int records = new PCP_ConfermaAppalto().inserisciLogIntegrazione(iddoc, "genera-xml-eform", "Elaborato", "XML_eForm", "", strToReturn, strToReturn, DateTime.Now, DateTime.Now, DateTime.Now, idpfu, -20, "OUT");

            return strToReturn;

        }

    }
}
