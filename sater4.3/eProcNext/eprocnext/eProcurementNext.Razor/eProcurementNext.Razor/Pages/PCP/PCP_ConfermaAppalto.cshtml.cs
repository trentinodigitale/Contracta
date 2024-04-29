using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using eProcurementNext.DashBoard;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data;
using System.Data.SqlClient;
using static eProcurementNext.CommonModule.Basic;
using Basic = eProcurementNext.CommonDB.Basic;

namespace eProcurementNext.Razor.Pages.PCP
{
    public class PCP_ConfermaAppalto : PageModel
    {

        public string? Conferma_Appalto(int iddoc, int idpfu, string operation)
        {
            string res = string.Empty;

            try
            {
                
                string tipoScheda = recuperaTipoScheda(iddoc);
                if (operation == "PCP_CreaAppalto" || string.IsNullOrEmpty(operation))
                {
                    switch (tipoScheda)
                    {
                        case "AD_3":
                        case "AD_5":
                        case "AD_2_25":
                        case "P7_2":
                        case "P2_16":
                        case "P2_19":
                        case "P2_20":
                            XMLESPD(iddoc, idpfu, obblig: false);
                            break;
                        case "P1_16":
                        case "P1_19":
                        case "P1_20":
                            XMLCN16(iddoc, idpfu, obblig: true);
                            XMLESPD(iddoc, idpfu, obblig: true);
                            break;
                        default:
                            break;
                    }

                }


                string urlToInvoke = "";

                switch (operation)
                {
                    case ("PCP_PubblicaAvviso"):
                        urlToInvoke = $@"/WebApiFramework/api/ConfermaAppalto/pubblicaAvviso?iddoc={iddoc}";
                        break;
                    case ("PCP_CancellaAppalto"):
                        urlToInvoke = $@"/WebApiFramework/api/ConfermaAppalto/cancellaAppalto?iddoc={iddoc}";
                        break;
                    case ("PCP_ModificaAppalto"):
                        urlToInvoke = $@"/WebApiFramework/api/ConfermaAppalto/modificaAppalto?iddoc={iddoc}";
                        break;
                    case ("PCP_RecuperaCIG"):
                        urlToInvoke =
                            $@"/WebApiFramework/api/ConfermaAppalto/recuperaCig?iddoc={iddoc}&idpfu={idpfu}&idAppalto={recuperaIdAppalto(iddoc)}";
                        break;
                    case ("PCP_CreaAppalto"):
                    default:
                        urlToInvoke = $@"/WebApiFramework/api/ConfermaAppalto/creaAppalto?iddoc={iddoc}&idpfu={idpfu}";
                        break;
                }


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
                    Basic.LogEvent(Basic.TsEventLogEntryType.Error, res, ApplicationCommon.Application["ConnectionString"], "PCP_ConfermaAppalto");
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

        public string XMLCN16(int iddoc, int idpfu, bool obblig)
        {
            string strToReturn = "";
            string msgTitle = "";
            int msgIcon = 0;
            string msgBody = "";
            DashBoardMod.ExecuteProcess(new Session.Session(), "BANDO_GARA", "XML_CN16", iddoc, idpfu, ref msgTitle, ref msgIcon, ref msgBody, ApplicationCommon.Application.ConnectionString);
            if (msgIcon != MSG_INFO && msgBody != "???XML_CN16??? eseguito correttamente")
            {
                if (!string.IsNullOrEmpty(msgTitle))
                {
                    msgTitle = msgTitle.Replace("con il download", "");
                }
                if (obblig)
                {
                    throw new Exception(msgBody);
                }
            }

            try
            {
                var cdf = new CommonDbFunctions();
                TSRecordSet rsTEMPLATE_CONTEST = cdf.GetRSReadFromQuery_(
                        "select top 1 payload from Document_E_FORM_PAYLOADS with(nolock) where idheader = " + iddoc + " and operationType = 'CN16' order by idRow desc"
                        , ApplicationCommon.Application.ConnectionString)!;
                strToReturn = CStr(rsTEMPLATE_CONTEST["payload"]);
            }
            catch
            {
                if (obblig)
                {
                    throw new Exception("Errore caricamento xml cn16");
                }
            }

            int records = inserisciLogIntegrazione(iddoc, "genera-xml-eform", "Elaborato", "XML_eForm", "", strToReturn, strToReturn, DateTime.Now, DateTime.Now, DateTime.Now, idpfu, -20, "OUT");

            return strToReturn;

        }

        public string XMLESPD(int iddoc, int idpfu, bool obblig)
        {
            string strToReturn;

            var cdf = new CommonDbFunctions();
            try
            {

                TSRecordSet rsCheckFlagYES = cdf.GetRSReadFromQuery_(
                    "select idrow from ctl_doc_value with (nolock) where idHeader = " + iddoc + " and dse_id='DGUE' and DZT_Name ='PresenzaDGUE' and value='si'"
                    , ApplicationCommon.Application.ConnectionString)!;

                if (rsCheckFlagYES.RecordCount == 0)
                {
                    if (obblig)
                    {
                        throw new Exception();
                    }
                    return "";
                }
                else
                {
                    //--parto dal BANDO_GARA
                    //--SELECT * from CTL_DOC where Id = iddoc
                    //--prendo il 'TEMPLATE_CONTEST' con LinkedDoc = all'id del BANDO_GARA
                    TSRecordSet rsTEMPLATE_CONTEST = cdf.GetRSReadFromQuery_(
                        "SELECT id from CTL_DOC with (nolock) where LinkedDoc = " + iddoc + "and TipoDoc = 'TEMPLATE_CONTEST' and Deleted = 0 and JumpCheck = 'DGUE_MANDATARIA'"
                        , ApplicationCommon.Application.ConnectionString)!;

                    int iddocTEMPLATE_CONTEST = CInt(rsTEMPLATE_CONTEST["Id"]);
                    //--prendo il 'TEMPLATE_CONTEST' con LinkedDoc = all'id del 'TEMPLATE_CONTEST'
                    TSRecordSet rsMODULO_TEMPLATE_REQUEST = cdf.GetRSReadFromQuery_(
                        "SELECT id from CTL_DOC with (nolock) where LinkedDoc = " + iddocTEMPLATE_CONTEST + " and TipoDoc = 'MODULO_TEMPLATE_REQUEST' and Deleted = 0 and JumpCheck = 'DGUE_MANDATARIA'"
                        , ApplicationCommon.Application.ConnectionString)!;

                    int iddocMODULO_TEMPLATE_REQUEST = CInt(rsMODULO_TEMPLATE_REQUEST["Id"]);
                    string urlToInvoke = ApplicationCommon.Application["WEBSERVERAPPLICAZIONE_INTERNO"] + ApplicationCommon.Application["strVirtualDirectory"] + "/report/ESPD_REQUEST.ASP?IDDOC=" + iddocMODULO_TEMPLATE_REQUEST;


                    strToReturn = invokeUrl(urlToInvoke);

                    int records = inserisciLogIntegrazione(iddoc, "genera-xml-espd", "Elaborato", "XML_ESPD", "", strToReturn, strToReturn, DateTime.Now, DateTime.Now, DateTime.Now, idpfu, -20, "OUT");


                    return strToReturn;

                }

            }
            catch
            {
                throw new Exception("Errore caricamento xml dgue");
            }


        }

        public int inserisciLogIntegrazione(int idDoc, string operazioneRichiesta, string statoRichiesta, string datoRichiesto, string msgError, string inputWS, string outputWS, DateTime dataIn, DateTime dataExecuted, DateTime dataFinalizza, int idPfu, int idAzi, string inOut)
        {
            SqlCommand cmd;
            SqlConnection conn;
            SqlDataAdapter da;

            conn = new SqlConnection(ApplicationCommon.Application.ConnectionString);
            cmd = new SqlCommand();
            cmd.Connection = conn;

            int rec = 0;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idDoc", idDoc);
            cmd.Parameters.AddWithValue("@integrazione", "PCP");
            cmd.Parameters.AddWithValue("@operazioneRichiesta", operazioneRichiesta);
            cmd.Parameters.AddWithValue("@statoRichiesta", statoRichiesta);
            cmd.Parameters.AddWithValue("@datoRichiesto", datoRichiesto);
            cmd.Parameters.AddWithValue("@msgError", msgError);
            cmd.Parameters.AddWithValue("@inputWS", inputWS);
            cmd.Parameters.AddWithValue("@outputWS", outputWS);
            cmd.Parameters.AddWithValue("@dataIn", dataIn);
            cmd.Parameters.AddWithValue("@dataExecuted", dataExecuted);
            cmd.Parameters.AddWithValue("@dataFinalizza", dataFinalizza);
            cmd.Parameters.AddWithValue("@idPfu", idPfu);
            cmd.Parameters.AddWithValue("@idAzi", idAzi);
            cmd.Parameters.AddWithValue("@inOut", inOut);

            string strSql = "insert into Services_Integration_Request(" +
                "idRichiesta," +
                "integrazione," +
                "operazioneRichiesta," +
                "statoRichiesta," +
                "datoRichiesto," +
                "msgError," +
                "numretry," +
                "inputWS," +
                "outputWS," +
                "isOld," +
                "dateIn, " +
                "DataExecuted," +
                "DataFinalizza," +
                "idPfu," +
                "idAzi," +
                "InOut)  VALUES(";
            strSql +=
                "@idDoc," +
                "@integrazione," +
                "@operazioneRichiesta," +
                "@statoRichiesta," +
                "@datoRichiesto," +
                "@msgError," +
                "0," +
                "@inputWS," +
                "@outputWS," +
                "0," +
                "@dataIn," +
                "@dataExecuted," +
                "@dataFinalizza," +
                "@idPfu," +
                "@idAzi," +
                "@inOut)";

            cmd.CommandType = CommandType.Text;
            cmd.CommandText = strSql;

            try
            {
                conn.Open();
                rec = cmd.ExecuteNonQuery();
                conn.Close();
            }
            catch (Exception ex)
            {
                string errore = ex.Message;
                throw;
            }

            return rec;
        }

        public string recuperaIdAppalto(int iddoc)
        {
            var cdf = new CommonDbFunctions();

            string strSql = "SELECT pcp_CodiceAppalto FROM Document_PCP_Appalto with(nolock) WHERE idHeader = " + iddoc;
            TSRecordSet rs = cdf.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString)!;

            return CStr(rs["pcp_CodiceAppalto"]);
        }
        public string recuperaTipoScheda(int iddoc)
        {
            var cdf = new CommonDbFunctions();

            string strSql = "SELECT pcp_TipoScheda FROM Document_PCP_Appalto with(nolock) where idHeader = " + iddoc;
            TSRecordSet rs = cdf.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString)!;

            string tipoScheda = CStr(rs["pcp_TipoScheda"]);

            if (string.IsNullOrEmpty(tipoScheda))
            {
                throw new Exception("Tipo scheda non recuperato correttamente");
            }

            return tipoScheda;
        }
       
        public enum TipoScheda
        {
            P1_16 = 1,
            AD_3 = 2,
            AD_4 = 6,
            AD_5 = 7,
            S2 = 3,
            P2_16 = 4,
            P6_1 = 8,
            P6_2 = 9,
            P7_2 = 10,
            AD_2_25 = 5,
            P7_1_2 = 11,
            P7_1_3 = 16,
            P1_19 = 17,
            P2_19 = 18,
            P2_20 = 19,
            P1_20 = 20
        }

    }
}
