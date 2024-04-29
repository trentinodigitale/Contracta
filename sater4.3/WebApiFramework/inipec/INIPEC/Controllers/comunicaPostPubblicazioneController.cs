using INIPEC.Library;
using INIPEC.Service.FLES;
using Microsoft.IdentityModel.Tokens;
using Org.BouncyCastle.Crypto;
using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using System.Web.Http;
using static INIPEC.Library.RispostaServizi;

namespace INIPEC.Controllers
{
    public class comunicaPostPubblicazioneController : ApiController
    {
        [HttpGet]
        [ActionName("creaScheda")]
        public HttpResponseMessage CreaScheda(int idRow, int iddoc, int idpfu)
        {
            /*
             * INPUT:
             *      - idRow     : id della tabella Services_Integration_Request
             *      - iddoc     : id della tabella Document_PCP_Appalto_Schede
             *      - idpfu     : utente che segue l'operazione, default -20 , backoffice
             *
             * OUTPUT:
             *      - output testuale in text/html nella forma 1#id_scheda in caso di esito positivo, 0#errore in caso di esito negativo
             */
            var esito = "1#OK";
            var strCause = string.Empty;
            var payload = string.Empty;
            var result = string.Empty;
            var pu = new PDNDUtils();
            FLESService flesService = new FLESService();

            DatiScheda datiScheda = null;

            var dateRequest = DateTime.Now;     //Data richiesta
            var dateExec = DateTime.Now;        //default, sovrascritto dopo
            var dateResponse = DateTime.Now;    //default, sovrascritto dopo

            try
            {
                const string nomeContesto = "Comunica post pubblicazione";
                const string nomeServizio = "/crea-scheda";

                pu.InsertTrace("PCP", $"Inizio CreaScheda per idRow {idRow} ed iddoc {iddoc}", iddoc);

                /*
                 * 0.   RECUPERIAMO I DATI TRASVERSALI PER QUALSIASI SCHEDA. COME L'IDGARA PER POI EFFETTUARE DEI CONTROLLI DI CONGRUITA'
                 */
                strCause = "Chiamata a getDatiScheda";
                datiScheda = pu.getDatiScheda(iddoc);

                if (string.IsNullOrEmpty(datiScheda.statoScheda))
                    throw new ApplicationException("Recupero dati scheda fallito");

                if (string.IsNullOrEmpty(datiScheda.idAppalto))
                    throw new ApplicationException("Conferma scheda non possibile in mancanza dell'id appalto");

                //Per poter fare il crea-scheda, la scheda deve essere in uno stato coerente. cioè non dobbiamo ancora aver richiesto niente lato anac ( con successo ).
                //  questa condizione la otteniamo verificando che per noi sia ancora nello stato iniziale di 'InvioInCorso' o che sia andato in errore un crea-scheda
                if (datiScheda.statoScheda.ToUpper() != "INVIOINCORSO" && datiScheda.statoScheda.ToUpper() != "ERRORECREAZIONE")
                    throw new ApplicationException($"Crea scheda non possibile per lo stato {datiScheda.statoScheda}");

                strCause = "Recupero il tipo scheda della gara";
                var tipoSchedaGara = pu.recuperaTipoSchedaGara(datiScheda.idgara);

                /*
                 *  1.  SWITCH SULL'OPERATION PER EFFETTUARE CONTROLLI O GESTIONI SPECIFICHE IN BASE AL TIPO SCHEDA
                 *  2.  CREAZIONE DEL PAYLOAD IN BASE ALLA SCHEDA CHE SI VUOLE INVIARE.
                 */
                switch (datiScheda.tipoScheda.ToUpper())
                {
                    case "S2":

                        //La scheda S2 può essere fatta solo a fronte di un appalto con P1_16 o P7_2 o P2_16 o P1_19 o P2_19, P1_20, P2_20
                        if (tipoSchedaGara != TipoScheda.P1_16 && 
                                    tipoSchedaGara != TipoScheda.P7_2 && 
                                    tipoSchedaGara != TipoScheda.P2_16 && 
                                    tipoSchedaGara != TipoScheda.P1_19 && 
                                    tipoSchedaGara != TipoScheda.P2_19 && 
                                    tipoSchedaGara != TipoScheda.P2_20 && 
                                    tipoSchedaGara != TipoScheda.P7_1_2 && 
                                    tipoSchedaGara != TipoScheda.P7_1_3 &&
                                    tipoSchedaGara != TipoScheda.P1_20)
                            throw new ApplicationException("Il crea-scheda per la S2 può essere effettuato solo a fronte di una P1_16, P7_2, P2_16, P1_19, P1_20, P2_19, P2_20, P7_1_2, P7_1_3");

                        strCause = "Creazione payload scheda S2";
                        payload = pu.getPayloadS2(datiScheda.idgara, datiScheda.idAppalto);

                        break;

                    case "S1":

                        //La scheda S1 può essere fatta solo a fronte di un appalto con P1_16 o P7_1_2 o P2_16, P7_1_3, P1_20 o P2_20
                        if (tipoSchedaGara != TipoScheda.P1_16 && tipoSchedaGara != TipoScheda.P7_1_2 && tipoSchedaGara != TipoScheda.P2_16 && tipoSchedaGara != TipoScheda.P7_1_3 && tipoSchedaGara != TipoScheda.P2_20 && tipoSchedaGara != TipoScheda.P1_20)
                            throw new ApplicationException("Il crea-scheda per la S1 può essere effettuato solo a fronte di una P1_16, di una P7_1_2, di una P2_16, di una P7_1_3, di una P2_20 o di una P1_20");

                        strCause = "Creazione payload scheda S1";
                        payload = pu.getPayloadS1(datiScheda.idgara, datiScheda.idAppalto);

                        break;

                    case "A1_29":

                        //La scheda A1_29 può essere fatta solo a fronte di un appalto con P1_16
                        if (tipoSchedaGara != TipoScheda.P1_16 && datiScheda.DatiElaborazione != "NON_AGG")
                            throw new ApplicationException("Il crea-scheda per la A1_29 può essere effettuato solo a fronte di una P1_16");


                        strCause = "Creazione payload scheda A1_29";
                        payload = pu.getPayloadA1_29(datiScheda.idgara, datiScheda.idAppalto, datiScheda.IdDoc_Scheda, datiScheda.CIG, datiScheda.DatiElaborazione);

                        break;

                    case "A2_29":

                        //La scheda A2_29 può essere fatta solo a fronte di un appalto con P2_16
                        if (tipoSchedaGara != TipoScheda.P2_16)
                            throw new ApplicationException("Il crea-scheda per la A2_29 può essere effettuato solo a fronte di una P2_16");


                        strCause = "Creazione payload scheda A2_29";
                        payload = pu.getPayloadA2_29(datiScheda.idgara, datiScheda.idAppalto, datiScheda.IdDoc_Scheda);

                        break;

                    case "S3":

                        strCause = "Creazione payload scheda S3";
                        payload = pu.getPayloadS3(datiScheda.idgara, datiScheda.idAppalto, datiScheda.IdDoc_Scheda);

                        break;
                    case "SC1":
                        strCause = "Creazione payload scheda SC1";
                        payload = pu.getPayloadSC1(datiScheda.idgara, datiScheda.idAppalto, datiScheda.IdDoc_Scheda);

                        break;
                    case "NAG":
                        strCause = "Creazione payload scheda NAG";
                        payload = pu.getPayloadNAG(datiScheda.idgara, datiScheda.IdDoc_Scheda, datiScheda.CIG, datiScheda.DatiElaborazione);
                        break;
                    case "A7_1_2":
                        strCause = "Creazione payload scheda A7_1_2";
                        payload = pu.getPayloadA7_1_2(datiScheda.idgara, datiScheda.idAppalto, datiScheda.IdDoc_Scheda);
                        break;
                    case "A1_32":

                        //La scheda A1_32 può essere fatta solo a fronte di un appalto con P1_19
                        if (tipoSchedaGara != TipoScheda.P1_19)
                            throw new ApplicationException("Il crea-scheda per la A1_32 può essere effettuato solo a fronte di una P1_19");

                        strCause = "Creazione payload scheda A1_32";
                        payload = pu.getPayloadA1_32(datiScheda.idgara, datiScheda.idAppalto, datiScheda.IdDoc_Scheda);
                        break;
                    case "A2_32":
                        strCause = "Creazione payload scheda A2_32";
                        payload = pu.getPayloadA2_32(datiScheda.idgara, datiScheda.idAppalto, datiScheda.IdDoc_Scheda);
                        break;
                    case "A1_33":

                        //La scheda A1_33 può essere fatta solo a fronte di un appalto con P1_20
                        if (tipoSchedaGara != TipoScheda.P1_20)
                            throw new ApplicationException("Il crea-scheda per la A1_33 può essere effettuato solo a fronte di una P1_20");

                        strCause = "Creazione payload scheda A1_33";
                        payload = pu.getPayloadA1_33(datiScheda.idgara, datiScheda.idAppalto, datiScheda.IdDoc_Scheda);
                        break;
                    case "I1":
                        strCause = "Creazione payload scheda I1";
                        payload = flesService.getPayloadI1(datiScheda.IdDoc_Scheda, datiScheda.idAppalto);
                        break;
                    case "SA1":
                        strCause = "Creazione payload scheda SA1";
                        payload = flesService.getPayloadSA1(datiScheda.IdDoc_Scheda, datiScheda.idAppalto);
                        break;
                    case "A2_33":
                        strCause = "Creazione payload scheda A2_33";
                        payload = pu.getPayloadA2_33(datiScheda.idgara, datiScheda.idAppalto, datiScheda.IdDoc_Scheda);
                        break;
                    default:
                        throw new ApplicationException($"Generazione payload per creazione scheda non possibile per {datiScheda.tipoScheda}");
                }

                if (string.IsNullOrEmpty(payload))
                    throw new ApplicationException("Payload scheda vuoto");

                /*
                    3.    CREAZIONE DEL VOUCHER CON RELATIVA VERIFICA DI SUCCESSO.
                            Crearlo in un punto vicino all'invocazione del WS per non superare il tempo di vita
                */
                strCause = "Recupero Dati Per Voucher";
                var dati = pu.recuperaDatiPerVoucher(datiScheda.idgara, nomeContesto, nomeServizio);

                strCause = "Chiamata alla Get Barer Token";
                var objVoucher = pu.GetBarerToken(dati, iddoc);

                if (objVoucher == null || string.IsNullOrEmpty(objVoucher.voucher))
                    throw new ApplicationException("Fallita la generazione del voucher");

                /*
                 * 4.    INVOCAZIONE DEL WS DI /CREA-SCHEDA
                 */

                var endpointContesto = dati.aud;

                if (string.IsNullOrEmpty(endpointContesto))
                    throw new ApplicationException($"L'endpoint per il contesto di {nomeServizio} è vuoto");

                var endpointContestuale = $"{endpointContesto}{nomeServizio}";

                dateExec = DateTime.Now; //Data esecuzione dell'invocazione

                //chiamata effettiva verso ANAC/PCP/crea-scheda
                strCause = $"Chiamata al WS {endpointContestuale}";
                result = pu.postRequest(objVoucher.client, endpointContestuale, "", objVoucher.voucher, objVoucher.jwtWithData, HttpMethod.Post, body: payload, idDoc: iddoc);

                dateResponse = DateTime.Now; //Data di risposta del ws

                if (string.IsNullOrEmpty(result))
                    throw new ApplicationException($"output vuoto dal WS {endpointContestuale}");

                //La classe RispostaBase servirà principalmete per testare lo status e gli errori
                strCause = "Deserialize della response";
                var risposta = JsonSerializer.Deserialize<RispostaBase>(result);

                if (risposta.status == 200)
                {
                    var rispostaOk = JsonSerializer.Deserialize<RispostaCreaScheda>(result);

                    esito = $"1#{rispostaOk.idScheda}";

                    //pu.aggiornaScheda(iddoc, "InLavorazione", rispostaOk.idScheda);
                    pu.aggiornaScheda(iddoc, "Creato", rispostaOk.idScheda);

                    //Leghiamo alla gara una sentinella nello stato terminale di "Elaborato" con l'esito positivo dell'operazione e tutti i dati relativi alla richiesta
                    pu.inserisciLogIntegrazione(datiScheda.idgara, "crea-scheda", "Elaborato",
                        null, $"{datiScheda.tipoScheda}@@@{rispostaOk.idScheda}", "",
                        payload, result,
                        dateRequest, dateExec, dateResponse,
                        idpfu, dati.idAzi, "OUT");

                }
                else
                {
                    throw new ApplicationException($"Errore da crea-scheda {risposta.detail}");
                }

                /*
                 * 5.    SE IL CREA-SCHEDA È ANDATO A BUON FINE INVOCHIAMO SUBITO UN /CONFERMA-SCHEDA 
                 */
                strCause = "Invocazione del ConfermaScheda";
                return ConfermaScheda(idRow, iddoc, idpfu);

                /*
                HttpResponseMessage respConferma = ConfermaScheda(idRow, iddoc, idpfu);

                esito = respConferma.Content.ReadAsStringAsync().Result;

                if (esito.StartsWith("1#"))
                {
                    esito = esito.Remove(0, 2); //togliamo 1# all'inizio della stringa, perchè lo mette la return finale
                }*/

            }
            catch (ApplicationException e)
            {
                //Eccezione lanciata di proposito per uscire con un messaggio preciso
                esito = $"0#{e.Message}";
            }
            catch (Exception e)
            {
                //Eccezione di runtime, non prevista
                esito = $"0#{strCause} - {e}";
            }
            finally
            {
                //In caso di errore tracciamo l'anomalia e ripuliamo la variabile di esito, altrimenti è stato già fatto tutto
                if (esito.StartsWith("0#"))
                {
                    //esito = esito.Remove(0, 2); //togliamo lo 0#

                    //Cambiamo lo stato della scheda per evidenziare la mancata creazione. così da poter ripetere il crea-scheda sapendo anche che c'è stato un errore
                    //pu.aggiornaScheda(iddoc, "Invio_con_errori");
                    pu.aggiornaScheda(iddoc, "ErroreCreazione");

                    //Tracciamo nella ctl_trace l'anomalia
                    pu.InsertTrace("PCP", $"CreaScheda - ERRORE:{esito}", iddoc);

                    //Leghiamo alla gara una sentinella nello stato terminale di "Errore" con l'esito negativo dell'operazione e tutti i dati relativi alla richiesta
                    pu.inserisciLogIntegrazione(datiScheda.idgara, "crea-scheda", "Errore",
                        null, datiScheda.tipoScheda, esito,
                        payload, result,
                        dateRequest, dateExec, dateResponse,
                        idpfu, 0, "OUT");

                    // Gestione schede FLES
                    try
                    {
                        if (flesService.getListaSchede().Contains(datiScheda.tipoScheda))
                        {
                            flesService.updateStato(iddoc, datiScheda.tipoScheda, "ErroreCreazione");
                        }
                    }
                    catch { }

                }
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

        [HttpGet]
        [ActionName("ConfermaScheda")]
        public HttpResponseMessage ConfermaScheda(int idRow, int iddoc, int idpfu)
        {
            /*
             * INPUT:
             *      - idRow     : id della tabella Services_Integration_Request
             *      - iddoc     : id della tabella Document_PCP_Appalto_Schede
             *      - idpfu     : utente che segue l'operazione, default -20 , backoffice
             *
             * OUTPUT:
             *      - output testuale in text/html nella forma 1#Richiesta acquisita in caso di esito positivo, 0#errore in caso di esito negativo
             */
            var esito = "1#OK";
            var strCause = string.Empty;
            var payload = string.Empty;
            var result = string.Empty;
            var pu = new PDNDUtils();

            var dateRequest = DateTime.Now;     //Data richiesta
            var dateExec = DateTime.Now;       //default, sovrascritto dopo
            var dateResponse = DateTime.Now;   //default, sovrascritto dopo

            DatiScheda datiScheda = null;

            try
            {
                const string nomeContesto = "Comunica post pubblicazione";
                const string nomeServizio = "/conferma-scheda";

                pu.InsertTrace("PCP", $"Inizio ConfermaScheda per idRow {idRow} ed iddoc {iddoc}", iddoc);

                /*
                 * 0.   RECUPERO DATI + CONTROLLI
                 */
                strCause = "Chiamata a getDatiScheda";
                datiScheda = pu.getDatiScheda(iddoc);

                if (string.IsNullOrEmpty(datiScheda.statoScheda))
                    throw new ApplicationException("Recupero dati scheda fallito");

                if (string.IsNullOrEmpty(datiScheda.idScheda))
                    throw new ApplicationException("Conferma scheda non possibile in mancanza dell'id scheda");

                if (string.IsNullOrEmpty(datiScheda.idAppalto))
                    throw new ApplicationException("Conferma scheda non possibile in mancanza dell'id appalto");

                //Per poter fare il conferma scheda, la scheda da confermare deve essere in uno stato coerente. cioè "in lavorazione" per l'anac.
                //  questa condizione la otteniamo verificando che per noi sia effettivamente in lavorazione ( quindi scheda creata ma non confermata )
                //  oppure se c'è stato un crea scheda ma il conferma è andato in errore, quindi si può riprovare
                if (datiScheda.statoScheda.ToUpper() != "CREATO" && datiScheda.statoScheda.ToUpper() != "ERRORECONFERMA")
                    throw new ApplicationException($"Conferma scheda non possibile per lo stato {datiScheda.statoScheda}");

                /*
                    1.    CREAZIONE DEL VOUCHER CON RELATIVA VERIFICA DI SUCCESSO.
                            Crearlo in un punto vicino all'invocazione del WS per non superare il tempo di vita
                */
                strCause = "Recupero Dati Per Voucher";
                var dati = pu.recuperaDatiPerVoucher(datiScheda.idgara, nomeContesto, nomeServizio);

                strCause = "Chiamata alla Get Barer Token";
                var objVoucher = pu.GetBarerToken(dati, iddoc);

                if (objVoucher == null || string.IsNullOrEmpty(objVoucher.voucher))
                    throw new ApplicationException("Fallita la generazione del voucher");

                /*
                 * 2.   CREAZIONE DEL PAYLOAD DI CONFERMA
                 */

                payload = JsonSerializer.Serialize(new DtoConfermaScheda { idScheda = datiScheda.idScheda, idAppalto = datiScheda.idAppalto });

                /*
                 * 3.    INVOCAZIONE DEL WS DI /CONFERMA-SCHEDA
                 */

                var endpointContesto = dati.aud;

                if (string.IsNullOrEmpty(endpointContesto))
                    throw new ApplicationException($"L'endpoint per il contesto di {nomeServizio} è vuoto");

                var endpointContestuale = $"{endpointContesto}{nomeServizio}";

                dateExec = DateTime.Now; //Data esecuzione dell'invocazione

                //chiamata effettiva verso ANAC/PCP/conferma-scheda
                strCause = $"Chiamata al WS {endpointContestuale}";
                result = pu.postRequest(objVoucher.client, endpointContestuale, "", objVoucher.voucher, objVoucher.jwtWithData, HttpMethod.Post, body: payload, idDoc: iddoc);

                dateResponse = DateTime.Now; //Data di risposta del ws

                if (string.IsNullOrEmpty(result))
                    throw new ApplicationException($"output vuoto dal WS {endpointContestuale}");

                //La classe RispostaBase servirà principalmete per testare lo status e gli errori
                strCause = "Deserialize della response";
                var risposta = JsonSerializer.Deserialize<RispostaBase>(result);

                if (risposta.status == 200)
                {
                    esito = $"1#{risposta.title}";

                    pu.aggiornaScheda(iddoc, "Confermato");

                    //Inserisco una nuova sentinella di integrazione per richiede il giro di esito-operazione
                    pu.avviaEsitoOperazione(idpfu, iddoc, "conferma-scheda");

                    //Leghiamo alla gara una sentinella nello stato terminale di "Elaborato" con l'esito positivo dell'operazione e tutti i dati relativi alla richiesta
                    pu.inserisciLogIntegrazione(datiScheda.idgara, "conferma-scheda", "Elaborato",
                        null, $"{datiScheda.tipoScheda}@@@{esito}", "",
                        payload, result,
                        dateRequest, dateExec, dateResponse,
                        idpfu, dati.idAzi, "OUT");
                }
                else
                {
                    throw new ApplicationException($"Errore da {nomeServizio} {risposta.detail}");
                }

            }
            catch (ApplicationException e)
            {
                //Eccezione lanciata di proposito per uscire con un messaggio preciso
                esito = $"0#{e.Message}";
            }
            catch (Exception e)
            {
                //Eccezione di runtime, non prevista
                esito = $"0#{strCause} - {e}";
            }
            finally
            {
                //In caso di errore tracciamo l'anomalia e ripuliamo la variabile di esito
                if (datiScheda != null && esito.StartsWith("0#"))
                {
                    //esito = esito.Remove(0, 2); //togliamo lo 0#

                    //Cambiamo lo stato della scheda per evidenziare la mancata conferma. così da poter ripetere il conferma scheda ma NON rifare il crea scheda
                    //pu.aggiornaScheda(iddoc, "NonConfermato");
                    pu.aggiornaScheda(iddoc, "ErroreConferma");

                    //Tracciamo nella ctl_trace l'anomalia
                    pu.InsertTrace("PCP", $"ConfermaScheda - ERRORE:{esito}", iddoc);

                    //Leghiamo alla gara una sentinella nello stato terminale di "Errore" con l'esito negativo dell'operazione e tutti i dati relativi alla richiesta
                    pu.inserisciLogIntegrazione(datiScheda.idgara, "conferma-scheda", "Errore",
                        null, datiScheda.tipoScheda, esito,
                        payload, result,
                        dateRequest, dateExec, dateResponse,
                        idpfu, 0, "OUT");

                    // Gestione schede FLES
                    try
                    {
                        FLESService flesService = new FLESService();
                        if (flesService.getListaSchede().Contains(datiScheda.tipoScheda))
                        {
                            flesService.updateStato(iddoc, datiScheda.tipoScheda, "ErroreConferma");
                        }
                    } catch { }

                }
            }

            //Questo controller venendo chiamato da un giro di backoffice dovrà avere sempre un output 1#.. così da non tornare errore e chiudere sempre il processo
            //  - sarà la sentinella di innesco a far risalire un errore o un ok tramite lo statoRichiesta ed il processo di finalizza
            return new HttpResponseMessage()
            {
                Content = new StringContent(
                    esito,
                    Encoding.UTF8,
                    "text/html"
                )
            };
        }

        [HttpGet]
        [ActionName("payloadS2")]
        public HttpResponseMessage payloadS2(int iddoc = -20, int idpfu = -20, string idAppalto = "")
        {
            /*CONTROLLER DI TEST PER RECUPERARE SOLO IL PAYLOAD DELLA SCHEDA S2*/
            if (iddoc <= 0)
                throw new Exception("Parametro iddoc obbligatorio. deve contenere l'id della gara");

            if (string.IsNullOrEmpty(idAppalto))
                throw new Exception("Parametro idAppalto obbligatorio");

            PDNDUtils pu = new PDNDUtils();
            string json = pu.getPayloadS2(iddoc, idAppalto);

            return new HttpResponseMessage()
            {
                Content = new StringContent(
                    json,
                    Encoding.UTF8,
                    "application/json"
                )
            };

        }

        [HttpGet]
        [ActionName("payloadS1")]
        public HttpResponseMessage payloadS1(int iddoc = -20, int idpfu = -20, string idAppalto = "")
        {
            /*CONTROLLER DI TEST PER RECUPERARE SOLO IL PAYLOAD DELLA SCHEDA S1*/
            if (iddoc <= 0)
                throw new Exception("Parametro iddoc obbligatorio. deve contenere l'id della gara");

            if (string.IsNullOrEmpty(idAppalto))
                throw new Exception("Parametro idAppalto obbligatorio");

            PDNDUtils pu = new PDNDUtils();
            string json = pu.getPayloadS1(iddoc, idAppalto);

            return new HttpResponseMessage()
            {
                Content = new StringContent(
                    json,
                    Encoding.UTF8,
                    "application/json"
                )
            };

        }

        [HttpGet]
        [ActionName("payloadA1_29")]
        public HttpResponseMessage payloadA1_29(int iddoc = -20, int idpfu = -20, string idAppalto = "", int IdDoc_Scheda = 0)
        {
            /*CONTROLLER DI TEST PER RECUPERARE SOLO IL PAYLOAD DELLA SCHEDA A1_29*/
            if (iddoc <= 0)
                throw new Exception("Parametro iddoc obbligatorio. deve contenere l'id della gara");

            if (string.IsNullOrEmpty(idAppalto))
                throw new Exception("Parametro idAppalto obbligatorio");

            PDNDUtils pu = new PDNDUtils();
            string json = pu.getPayloadA1_29(iddoc, idAppalto, IdDoc_Scheda);

            return new HttpResponseMessage()
            {
                Content = new StringContent(
                    json,
                    Encoding.UTF8,
                    "application/json"
                )
            };

        }

        [HttpGet]
        [ActionName("payloadA2_29")]
        public HttpResponseMessage payloadA2_29(int iddoc = -20, int idpfu = -20, string idAppalto = "", int IdDoc_Scheda = 0)
        {
            /*CONTROLLER DI TEST PER RECUPERARE SOLO IL PAYLOAD DELLA SCHEDA A2_29*/
            if (iddoc <= 0)
                throw new Exception("Parametro iddoc obbligatorio. deve contenere l'id della gara");

            if (string.IsNullOrEmpty(idAppalto))
                throw new Exception("Parametro idAppalto obbligatorio");

            PDNDUtils pu = new PDNDUtils();
            string json = pu.getPayloadA2_29(iddoc, idAppalto, IdDoc_Scheda);

            return new HttpResponseMessage()
            {
                Content = new StringContent(
                    json,
                    Encoding.UTF8,
                    "application/json"
                )
            };

        }

        [HttpGet]
        [ActionName("payloadS3")]
        public HttpResponseMessage payloadS3(int iddoc = -20, int idpfu = -20, string idAppalto = "", int IdDoc_Scheda = 0)
        {
            /*CONTROLLER DI TEST PER RECUPERARE SOLO IL PAYLOAD DELLA SCHEDA S3*/
            if (iddoc <= 0)
                throw new Exception("Parametro iddoc obbligatorio. deve contenere l'id della gara");

            if (string.IsNullOrEmpty(idAppalto))
                throw new Exception("Parametro idAppalto obbligatorio");

            PDNDUtils pu = new PDNDUtils();
            string json = pu.getPayloadS3(iddoc, idAppalto, IdDoc_Scheda);

            return new HttpResponseMessage()
            {
                Content = new StringContent(
                    json,
                    Encoding.UTF8,
                    "application/json"
                )
            };

        }

        [HttpGet]
        [ActionName("payloadSC1")]
        public HttpResponseMessage payloadSC1(int iddoc = -20, int idpfu = -20, string idAppalto = "", int IdDoc_Scheda = 0)
        {
            /*CONTROLLER DI TEST PER RECUPERARE SOLO IL PAYLOAD DELLA SCHEDA SC1*/
            if (iddoc <= 0)
                throw new Exception("Parametro iddoc obbligatorio. deve contenere l'id della gara");

            if (string.IsNullOrEmpty(idAppalto))
                throw new Exception("Parametro idAppalto obbligatorio");

            PDNDUtils pu = new PDNDUtils();
            string json = pu.getPayloadSC1(iddoc, idAppalto, IdDoc_Scheda);

            return new HttpResponseMessage()
            {
                Content = new StringContent(
                    json,
                    Encoding.UTF8,
                    "application/json"
                )
            };

        }

        private int getIdGara(int iddoc)
        {
            var idGara = 0;
            var strconn = ConfigurationManager.AppSettings["db.conn"];
            var conn = new SqlConnection(strconn);
            var cmd = new SqlCommand
            {
                Connection = conn
            };

            try
            {
                const string strSql = "select idHeader as idgara from Document_PCP_Appalto_Schede with(nolock) where idRow = @iddoc";

                cmd.CommandText = strSql;
                cmd.Parameters.AddWithValue("@iddoc", iddoc);
                conn.Open();
                var dato = cmd.ExecuteScalar();

                if (dato is null)
                {
                    throw new ApplicationException("Fallito il recupero dell'id gara dalla Document_PCP_Appalto_Schede");
                }

                idGara = Convert.ToInt32(dato);
            }
            finally
            {
                conn.Close();
            }

            return idGara;

        }



    }
}
