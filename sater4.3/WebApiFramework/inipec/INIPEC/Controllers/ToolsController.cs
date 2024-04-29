using INIPEC.Library;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Web;
using System.Web.Http;


namespace INIPEC.Controllers
{
    public class ToolsController : ApiController
    {

        //private static readonly string BasePath = AppDomain.CurrentDomain.BaseDirectory;




        /// <summary>
        /// /api/Tools/testPCP
        /// </summary>
        /// <param name="iddoc"></param>
        /// <returns>1#OK or 0#Error</returns>
        [HttpGet]
        [ActionName("testPCP")]
        public HttpResponseMessage testPCP(int iddoc = -20)
        {
            string esito = "1#OK";
            string strCause = "testPCP - START";
            string json = string.Empty;

            try
            {
                PDNDUtils pu = new PDNDUtils();

                // prima del recuperaDatiPerVoucher devo recuperare Contesto e Servizio 

                Dati_Base datibase = pu.recuperaContestoEServizio(iddoc);

                Dati_PCP dati = pu.recuperaDatiPerVoucher(iddoc, datibase.PCP_CONTESTO, datibase.PCP_SERVIZIO);
                //#if DEBUG
                //                if(String.IsNullOrEmpty(dati.cfRP))
                //                {
                //                    dati.cfRP = "USRRUP20A01A110A";
                //                }
                //                if(dati.cfSA.ToUpper().StartsWith("IT"))
                //                {
                //                    dati.cfSA = dati.cfSA.ToUpper().Remove(0, 2);
                //                }
                //                if(String.IsNullOrEmpty(dati.regCodiceComponente))
                //                {
                //                    dati.regCodiceComponente = "058f6af5-eee0-4121-ac28-7a3723ceddcf";
                //                }
                //#endif
                strCause = "testPCP - start Region Generazione Voucher ANAC";

                #region Generazione Voucher ANAC

                string jwtWithData = "";
                string hashedjwt = "";
                string ploadJson = "";
                string stringJws = "";
                string voucher = "";
                HttpMethod method;
                PCPPayloadWithData payload;
                PDNDClient client;
                PCPPayloadWithHash mainPcpPayLoad;
                Task<string> PDNDResponse;
                try
                {
                    payload = pu.getDatiPerVoucher(dati);
                    client = new PDNDClient(payload, dati);
                    client.clientId = dati.clientId;
                    jwtWithData = client.composeComplementaryJWT(payload, dati);
                    hashedjwt = client.computeHash(jwtWithData);
                    mainPcpPayLoad = new PCPPayloadWithHash();
                    mainPcpPayLoad.purposeId = payload.purposeId;
                    ploadJson = JsonSerializer.Serialize(mainPcpPayLoad);
                    stringJws = client.composeJWT(ploadJson, hashedjwt, dati, iddoc);
                    method = HttpMethod.Post;
                    voucher = pu.GetVoucher(client, stringJws, method,iddoc);
                    //voucher = PDNDResponse.Result;
                }
                catch (Exception ex1)
                {
                    //--https://jwt.io/                    
                    pu.InsertTrace("PCP", $"testPCP - Eccezione : {ex1}");
                    pu.InsertTrace("PCP", "testPCP - Per decodificare andare sul sito https://jwt.io/ e togliere tutto quello prima di #@# jwtWithData#@#" + jwtWithData);
                    pu.InsertTrace("PCP", "testPCP - Utile per debug PDND - Per decodificare andare sul sito https://jwt.io/ e togliere tutto quello prima di #@# stringJws#@#" + stringJws);                    
                    throw;
                }
                #endregion

                strCause = "testPCP - start recuperaMetodoDaServizio";

                //Ogni servizio (endpoint) ha un metodo associato, lo recupero da db
                method = pu.recuperaMetodoDaServizio(datibase.PCP_SERVIZIO);//    da   ti.purposeId);

                string endpointContesto = dati.aud;
                string endpointContestuale = $"{endpointContesto}{datibase.PCP_SERVIZIO}";  // dato recuperato da db
                endpointContestuale = endpointContestuale;

                strCause = $"testPCP - start get or post {"servizio scelto recuperato da db"} verso ANAC";

                string result = string.Empty;
                if (method == HttpMethod.Get)
                {
                    //throw new NotImplementedException("testPCP GET not implemented");

                    // recuperare i parametri e inserirli nella composizione della chiamata

                    Dictionary<string, string> data = new Dictionary<string, string>();
                    string parametri = datibase.PCP_PARAMETRI; // il valore sarà quello recuperato dal db
                    string[] arParametri = parametri.Split('&');
                    foreach (string s in arParametri)
                    {
                        string[] par1 = s.Split('=');
                        data.Add(par1[0], par1[1]);
                    }
                    result = pu.sendRequest(client, endpointContestuale, "", voucher, jwtWithData, method, parametri: data, idDoc: iddoc);
                }
                else if (method == HttpMethod.Post)
                {
                    json = datibase.PCP_JSON;
                    //chiamata effettiva verso ANAC /crea-appalto
                    result = pu.postRequest(client, endpointContestuale, "", voucher, jwtWithData, method, body: json, idDoc: iddoc);
                }

                //string rispostaJson = string.Empty;
                string datoRichiesto = string.Empty;
                //bool bEsito = false;

                if (datibase.PCP_SERVIZIO.Contains("crea-appalto"))
                {
                    //RispostaCreaAppalto risposta = JsonSerializer.Deserialize<RispostaCreaAppalto>(result);
                    //rispostaJson = JsonSerializer.Serialize(risposta);
                    //if (risposta.status == 200)
                    //{
                    //    bEsito = true;
                    //}
                    datoRichiesto = "IdAppalto";
                }
                else if (datibase.PCP_SERVIZIO.Contains("esito-operazione"))
                {
                    //RispostaServizi risposta = JsonSerializer.Deserialize<RispostaServizi>(result);
                    //rispostaJson = JsonSerializer.Serialize(risposta);
                    //if (risposta.status == 200)
                    //{
                    //    bEsito = true;
                    //}
                    datoRichiesto = "Stato Appalto";
                }
                else if (datibase.PCP_SERVIZIO.Contains("getBy"))
                {
                    // CREARE classe per risposta da questo servizio 
                    //RispostaAusaCDC risposta = JsonSerializer.Deserialize<RispostaAusaCDC>(result);
                    //rispostaJson = JsonSerializer.Serialize(risposta);
                    //if (risposta.code == 200 && risposta.status.ToUpper() == "OK")
                    //{
                    //    bEsito = true;

                    //}
                    datoRichiesto = "Centro di costo";
                }
                else if (datibase.PCP_SERVIZIO.Contains("recupera-cig"))
                {
                    //RispostaCig risposta = JsonSerializer.Deserialize<RispostaCig>(result);
                    //rispostaJson = JsonSerializer.Serialize(risposta);
                    //if (risposta.status == 200)
                    //{
                    //    bEsito = true;
                    //}
                    datoRichiesto = "CIG per Lotti";
                }
                //else
                //{
                //    rispostaJson = "Servizio la cui risposta non è ancora stata gestita o dati ricevuti non corretti";
                //}

                //RispostaCreaAppalto risposta = JsonSerializer.Deserialize<RispostaCreaAppalto>(result);

                //if (bEsito)
                //{
                //se ho un 200 da ANAC dopo la chiamata POST /crea-appalto mi devo salvare l'idAppalto
                //che mi ha restituito la chiamata nella tabella Document_PCP_Appalto, colonna pcp_CodiceAppalto,
                //in modo sincrono vado subito sulla /conferma-appalto (richiamo direttamente l'altra action nello stesso controller)
                //string idAppalto = risposta.idAppalto;
                //pu.AggiornaIdAppalto(iddoc, idAppalto);
                pu.inserisciLogIntegrazione(iddoc, datibase.PCP_SERVIZIO, "Elaborato", null, "Test: " + datoRichiesto, "", json, result, DateTime.Now, DateTime.Now, DateTime.Now, -20, dati.idAzi, "OUT");


                // ritornare risposta al chiamante??
                //}
                //else
                //{
                //    //se non ho un 200 da ANAC, loggo la risposta e ritorno l'errore a video
                //    //TODO: implementare controllo, se ho già l'idAppalto, ANAC restituirà una response del genere:
                //    //{"status":400,"title":"KO","detail":"Errore","type":"about:blank","errori":[{"idTipologica":"errori","codice":"ERR38"}]}
                //    //chiamare direttamente al conferma appalto? oppure bloccare la richiesta?
                //    //forse è meglio spostare questo controllo a monte del controller!

                //    pu.inserisciLogIntegrazione(iddoc, datibase.PCP_SERVIZIO, "Elaborato", "Test: " + datoRichiesto, "ERRORE", jwtWithData, result, DateTime.Now, DateTime.Now, DateTime.Now, -20, dati.idAzi, "OUT");
                //    throw new ApplicationException($"l'operazione {datibase.PCP_SERVIZIO} non è stata eseguita correttamente");
                //}

            }
            catch (ConfigurationException ex1)
            {
                esito = "0#" + ex1.Message;
            }
            catch (ApplicationException e)
            {
                esito = "0#" + e.Message;
            }
            catch (Exception e)
            {
                //Se non mi trovo su un eccezione lanciata dal codice voglio la stack trace completa
                esito = "0#" + strCause + " -- " + e.ToString();
            }

            return new HttpResponseMessage()
            {
                Content = new StringContent(
                        esito,
                        Encoding.UTF8,
                        "text/html"
                    )
            };

        }



    }
}
