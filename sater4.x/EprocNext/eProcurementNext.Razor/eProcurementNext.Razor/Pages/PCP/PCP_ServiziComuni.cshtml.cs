using eProcurementNext.Application;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data;
using System.Data.SqlClient;
using static eProcurementNext.CommonModule.Basic;
using Basic = eProcurementNext.CommonDB.Basic;

namespace eProcurementNext.Razor.Pages.PCP
{
    public class PCP_ServiziComuni : PageModel
    {

        public string? esito_Operazione(int idRow, string operation)
        {
            

            string res = string.Empty;

            try
            {

                UpdateServiceIntegration(idRow, "InGestione");

                //iddoc conterrà l'idGara per i giri pre-pubblicazione. e l'idRow della Document_PCP_Appalto_Schede per i post pubblicazione. come le schede s1 ed s2
                var iddoc = recuperaIdDoc(idRow);
                DatiScheda datiS;

                string extraParams = "";

                if (operation.ToUpper() == "ESITOOPERAZIONECONFERMASCHEDA") //esitoOperazioneConfermaScheda
                {
                    datiS = getDatiScheda(CInt(iddoc), true);

                    if (datiS == null)
                        throw new ApplicationException("Errore nel recupero dei dati scheda");

                    extraParams = $"&tipoRicerca=TUTTI_ESITI&idRow={iddoc}&idScheda={datiS.idScheda}";
                }
                else
                {
                    //idAppalto = recuperaIdAppalto(CInt(iddoc));
                    datiS = getDatiScheda(CInt(iddoc));
                }

                string idAppalto = datiS.idAppalto;

                if (!string.IsNullOrEmpty(idAppalto))
                {
                    string urlToInvoke = "";
                    string tipoOperazione = "";
                    switch (operation)
                    {
                        case ("esitoOperazioneConfermaScheda"):
                        case ("SC_CONF"):
                            /*
                             * "codice":"SC_CONF",
                                "descrizione": {
                                    "it": "Conferma scheda",
                                    "en": "Conferma scheda"
                                }
                             */
                            tipoOperazione = "SC_CONF";
                            break;

                        case ("esitoOperazionePostPubblicaAvviso"):
                        case ("AV_PUBB"):
                            tipoOperazione = "AV_PUBB";
                            break;

                        case ("esitoOperazione"):
                        case ("AP_CONF"):
                        default:
                            tipoOperazione = "AP_CONF";
                            break;
                    }

                    urlToInvoke = $@"/WebApiFramework/api/ServiziComuni/esitoOperazione?idRowSIC={idRow}&iddoc={datiS.idgara}&idpfu={-20}&idAppalto={idAppalto}&tipoOperazione={tipoOperazione}{extraParams}";
                   
                    
                    if (!Uri.IsWellFormedUriString(urlToInvoke, UriKind.Absolute))
                    {
                        urlToInvoke = ApplicationCommon.Application["WEBSERVERAPPLICAZIONE_INTERNO"] + urlToInvoke;
                    }

                    res = invokeUrl(urlToInvoke);

                }
                else
                {
                    res = "0#IdAppalto non valorizzato";
                }
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
        public string? recuperaIdAppalto(int idDoc, bool bScheda = false)
        {
            var idAppalto = string.Empty;
            var cmd = new SqlCommand();
            var strConn = ApplicationCommon.Application.ConnectionString;
            var conn = new SqlConnection(strConn);

            cmd.Connection = conn;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idDoc", idDoc);

            var strSql = "SELECT pcp_CodiceAppalto FROM Document_PCP_Appalto with(nolock) WHERE idHeader = @idDoc";

            //Se sono su un esito-operazione post conferma scheda allora il perno dell'integrazione non è l'id gara ma l'id della document_pcp_appalto_schede
            if (bScheda)
            {
                strSql = @"select b.pcp_CodiceAppalto
	                            from document_pcp_appalto_schede a with(nolock)
			                            inner join document_pcp_appalto b with(nolock) on b.idHeader = a.idHeader
	                            where a.idRow = @iddoc";
            }

            cmd.CommandType = CommandType.Text;
            cmd.CommandText = strSql;

            conn.Open();
            object codice = cmd.ExecuteScalar();
            if(codice != null)
            {
                idAppalto = codice.ToString();
            }
            conn.Close();

            return idAppalto;
        }

        private DatiScheda getDatiScheda(int idrow, bool bScheda = false)
        {
            var datiScheda = new DatiScheda();
            //var strconn = ConfigurationManager.AppSettings["db.conn"];
            var strconn = ApplicationCommon.Application.ConnectionString;
            var conn = new SqlConnection(strconn);
            var cmd = new SqlCommand
            {
                Connection = conn
            };

            try
            {

                var strSql = @"SELECT idHeader as idgara, '' as statoScheda, '' as idScheda, isnull(pcp_CodiceAppalto,'') as idAppalto
                                    FROM Document_PCP_Appalto with(nolock) 
                                    WHERE idHeader = @idDoc";

                //Se sono su un esito-operazione post conferma scheda allora il perno dell'integrazione non è l'id gara ma l'id della document_pcp_appalto_schede
                if (bScheda)
                {
                    strSql = @"select a.idHeader as idgara, a.statoScheda, isnull(a.idScheda,'') as idScheda, isnull(b.pcp_CodiceAppalto,'') as idAppalto
	                                from document_pcp_appalto_schede a with(nolock)
			                                inner join document_pcp_appalto b with(nolock) on b.idHeader = a.idHeader
	                                where a.idRow = @iddoc";
                }

                cmd.CommandText = strSql;
                cmd.Parameters.AddWithValue("@iddoc", idrow);
                conn.Open();

                using var rs = cmd.ExecuteReader();

                if (rs.Read())
                {
                    datiScheda.idgara = (int)rs["idgara"];
                    datiScheda.statoScheda = (string)rs["statoScheda"];
                    datiScheda.idScheda = (string)rs["idScheda"];   //Guid ottenuto dal crea-scheda
                    datiScheda.idAppalto = (string)rs["idAppalto"]; //Guid ottenuto al conferma dell'appalto
                }
                else
                {
                    throw new ApplicationException("Dati scheda non trovati");
                }
            }
            finally
            {
                conn.Close();
            }

            return datiScheda;
        }

    }
    public class DatiScheda
    {
        public int idgara { get; set; }
        public string statoScheda { get; set; }
        public string idScheda { get; set; }
        public string idAppalto { get; set; }
        public string tipoScheda { get; set; }
    }
}
