using INIPEC.Library;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Net.Http;
using System.Runtime.InteropServices;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using System.Web;
using System.Web.Http;
using System.Web.Http.Results;
using static INIPEC.Library.RispostaServizi;


namespace INIPEC.Controllers
{
    public class ServiziComuniController : ApiController
    {

        [HttpGet]
        [ActionName("esitoOperazione")]
        public HttpResponseMessage esitoOperazione(int idRowSIC, int iddoc, int idpfu, string idAppalto, string tipoOperazione = "AP_CONF", string tipoRicerca = "ULTIMO_ESITO", int idRow = 0, string idScheda = "")
        {       
            string esito = "1#OK";
            string strCause = "esitoOperazione - START";

            PDNDUtils pu = new PDNDUtils();
            TipoScheda? tipoScheda = null;
            string statoEsitoOperazione = "";
            string messaggioEsito = string.Empty;
            string endpointWithQS = string.Empty;
            //string rispostaJson = String.Empty;
            Dati_PCP dati = null;
            string result = string.Empty;
            bool errorMaxRetry = false;

            try
            {
                //string erroreAppalto = string.Empty;

                // recuperare i dati dell'azienda dall'id della gara in modo da poter recuperare tutti i dati necessari a ottenere il token autorizzativo
                // questa operazione va fatta dopo aver recuperato tutti i dati necessari anche alla formazione del json dell scheda
                // altrimenti si rischia di utilizzare un token scaduto (i token hanno durata di 10 secondi)

                strCause = "recuperaTipoSchedaGara";
                tipoScheda = pu.recuperaTipoSchedaGara(iddoc);

                strCause = "recuperaDatiPerVoucher";
                dati = pu.recuperaDatiPerVoucher(iddoc, "Servizi comuni", "/esito-operazione");

                EsitoOperazione esitoOp = new EsitoOperazione() { idAppalto = idAppalto, tipoOperazione = tipoOperazione, tipoRicerca = tipoRicerca };

                strCause = "Serializzazione esitoOP";
                string json = JsonSerializer.Serialize(esitoOp);

                strCause = "recuperaMetodoDaServizio";
                HttpMethod method = pu.recuperaMetodoDaServizio("/esito-operazione");

                string endpointContesto = dati.aud;
                string endpointContestuale = $"{endpointContesto}/esito-operazione";

                strCause = "Chiamata alla Get Barer Token";
                var objVoucher = pu.GetBarerToken(dati, iddoc);

                strCause = "esecuzione della request";
                
                if (method == HttpMethod.Get)
                {
                    Dictionary<string, string> data = new Dictionary<string, string>();
                    data.Add("idAppalto", idAppalto);
                    data.Add("tipoOperazione", tipoOperazione);
                    data.Add("tipoRicerca", tipoRicerca);
                    result = pu.sendRequest(objVoucher.client, endpointContestuale, "", objVoucher.voucher, objVoucher.jwtWithData, method, parametri: data, idDoc: iddoc);
                }
                else if (method == HttpMethod.Post)
                {
                    result = pu.postRequest(objVoucher.client, endpointContestuale, "", objVoucher.voucher, objVoucher.jwtWithData, method, body: json, idDoc: iddoc);
                }

                strCause = "Gestione della risposta";

                endpointWithQS = endpointContestuale + "?idAppalto=" + idAppalto + "&tipoOperazione=" + tipoOperazione + "&tipoRicerca=" + tipoRicerca;
                RispostaServizi risposta = JsonSerializer.Deserialize<RispostaServizi>(result);
                //rispostaJson = JsonSerializer.Serialize(risposta);
                
                if (risposta.status == 200)
                {
                    #region Esempio risposta OK con esito.codice = ok
                    //listaEsiti deve avere lunghezza 1, migliorare il ciclo foreach successivo 
                    //"idAppalto=c40e1f2c-a5e0-4147-a488-4a9a1e253e23&tipoOperazione=AP_CONF&tipoRicerca=ULTIMO_ESITO"
                    //{
                    //    "status":200,
                    //    "title":"OK",
                    //    "detail":"Esecuzione avvenuta con successo",
                    //    "type":"about:blank",
                    //    "listaEsiti":[
                    //        {
                    //            "idAppalto":"c40e1f2c-a5e0-4147-a488-4a9a1e253e23",
                    //            "idScheda":"0891040b-87d0-45e3-86f8-bee9598d84ce",
                    //            "idAvviso":"afebdf01-c00b-47ac-89ce-436ad5a0a447",
                    //            "esito":{ "idTipologica":"esito","codice":"OK"},
                    //            "tipoOperazione":{ "idTipologica":"tipoOperazione","codice":"AP_CONF"},
                    //            "dataControllo":"2023-11-21T15:08:29.401+00:00","dettaglio":{ "idTipologica":"esitoOperazione","codice":"AP_CONF"}
                    //        }
                    //    ]
                    //}
                    #endregion

                    #region esempio di risposta OK con esito.codice = ko
                    /*
                    {
                        "listaEsiti": [
                    
                        {
                            "idAppalto": "ba9e2974-976e-484a-914b-ce88279fdc82",
                            "idScheda": "3266f893-e412-4098-8012-4f547144f2fd",
                            "idAvviso": null,
                            "esito": {
                                "idTipologica": "esito",
                                "codice": "KO"

                            },
                            "tipoOperazione": {
                                "idTipologica": "tipoOperazione",
                                "codice": "AP_CONF"

                            },
                            "dataControllo": "2023-12-13T16:04:33.769+01:00",
                            "dettaglio": {
                                "idTipologica": "esitoOperazione",
                                "codice": "AP_N_CONF"

                            },
                            "errori": [

                            {
                                "idTipologica": "errori",
                                "codice": "ERR46",
                                "dettaglio": "BT-5071-Lot deve contenere un valore dell'elenco di codici nuts-lvl3"

                            }
                            ]
                        }
                        ],
                        "status": 200,
                        "detail": "Esecuzione avvenuta con successo",
                        "title": "OK",
                        "type": "about:blank",
                        "errori": null
                    }*/
                    #endregion

                    //caso di default se nel foreach non troviamo mai un match
                    messaggioEsito = "0#Scheda non trovata nell'esito";

                    strCause = "Iteriamo sugli esiti";

                    foreach (var item in risposta.listaEsiti)
                    {
                        //Se sto verificando un esito di una scheda devo andarmi a cercare l'idScheda giusto, altrimenti va bene idAppalto come faceva prima

                        if ((tipoOperazione.ToUpper() != "SC_CONF" && idAppalto == item.idAppalto) || (tipoOperazione.ToUpper() == "SC_CONF" && idScheda == item.idScheda))
                        {
                            if (item.esito.codice == "KO")
                            {
                                statoEsitoOperazione = item.dettaglio.codice;

                                if (item.errori.Count > 0)
                                {
                                    messaggioEsito = $"0#{statoEsitoOperazione} : ";//{item.errori[0].dettaglio}";

                                    string listErrors = "";

                                    //Recuperiamo tutti gli errori, prima era cablato il recupero del solo elemento 0
                                    for(int i = 0; i < item.errori.Count; i++)
                                    {
                                        listErrors += $"{item.errori[i].codice} - {item.errori[i].dettaglio};";
                                    }

                                    messaggioEsito += listErrors;
                                }
                                else
                                {
                                    messaggioEsito = $"0#{statoEsitoOperazione} :GenericKO";
                                }
                            }
                            else
                            {
                                //Entriamo qui per il caso OK ( SUCCESS ) e WT ( WAIT )  
                                messaggioEsito = "1#OK";
                                statoEsitoOperazione = item.dettaglio.codice;
                            }
                            break;
                        }
                    }

                }

                /****
                 * FACCIAMO AVANZARE LO STATO DELLA SCHEDA A SECONDA DEL FLUSSO SUL QUALE CI TROVIAMO.
                 * se però da anac non abbiamo avuto uno stato di esito allora lasciamo su di noi lo status precedente della scheda
                 * e procediamo con un retry. al raggiungimento del max retry cambiamo anche lo stato della scheda oltre a smettere di riprovare
                 *****
                 */

                //Se ho avuto un status scheda da anac
                if (!string.IsNullOrEmpty(statoEsitoOperazione))
                {
                    //Se NON sono nel giro di "comunica post pubblicazione"
                    if (tipoOperazione.ToUpper() != "SC_CONF")
                    {
                        strCause = $"Passo stato della scheda appalto al valore {statoEsitoOperazione}";
                        pu.aggiornaRecordSchedaAppalto(iddoc, idpfu, pu.traduciTipoScheda(tipoScheda),
                            statoEsitoOperazione);

                    }
                    else
                    {
                        pu.aggiornaScheda(idRow, statoEsitoOperazione);
                    }
                }

                //E' ok se ho avuto una risposta valida e NON sono in uno stato di attesa
                if (risposta.status == 200 && messaggioEsito.StartsWith("1#") && !(statoEsitoOperazione == "AP_IN_CONF" || statoEsitoOperazione == "SC_IN_CONF" || statoEsitoOperazione == "AV_IN_PUBB") )
                {
                    string statoRichiestaLog = "Elaborato";

                    switch (tipoOperazione)
                    {
                        case ("AP_CONF"):

                            pu.inserisciLogIntegrazione(iddoc, "esito-operazione", statoRichiestaLog, pu.recuperaTipoSchedaGara(iddoc), "idAppalto", "", endpointWithQS, result, DateTime.Now, DateTime.Now, DateTime.Now, idpfu, dati.idAzi, "OUT");

                            pu.salvaIdAvviso(iddoc, risposta.listaEsiti[0].idAvviso);
                            pu.salvaIdScheda(iddoc, risposta.listaEsiti[0].idScheda);

                            pu.UpdateServiceIntegration(idRowSIC, "Elaborato");

                            ConfermaAppaltoController confermaAppaltoController = new ConfermaAppaltoController();
                            HttpResponseMessage recuperaCIGResponse = confermaAppaltoController.recuperaCig(iddoc, idpfu, idAppalto);

                            //Se AD2_25, P7_1_2, P7_1_3
                            TipoScheda tipoSchedaGara = pu.recuperaTipoSchedaGara(iddoc);
                            if (
                                tipoSchedaGara == TipoScheda.AD2_25 ||
                                tipoSchedaGara == TipoScheda.P7_1_2 ||
                                tipoSchedaGara == TipoScheda.P7_1_3 ||
                                tipoSchedaGara == TipoScheda.AD_3
                                )
                            {
                                if (recuperaCIGResponse.Content.ReadAsStringAsync().Result.StartsWith("1#"))
                                {
                                    //Se recupera cig avvenuta con successo, dovra essere richiamato il pubblica-avviso e il conseguente esito operazione per visualizzare lo stato dell avviso.
                                    return confermaAppaltoController.pubblicaAvviso(iddoc);
                                }
                                else
                                {
                                    return recuperaCIGResponse;
                                }

                            }

                            return recuperaCIGResponse;
                        case ("SC_CONF"):

                            //Se mi trovo su di un giro di comunica post pubblicazione ho l'idRow della scheda in input e recupero il tipo scheda da quest'ultimo
                            pu.inserisciLogIntegrazione(iddoc, "esito-operazione", statoRichiestaLog, pu.recuperaTipoScheda(idRow), tipoOperazione, "", endpointWithQS, result, DateTime.Now, DateTime.Now, DateTime.Now, idpfu, dati.idAzi, "OUT");

                            //Per il giro di comunica post pubblicazione è la pagina chiamante a gestire lo stato del record
                            //pu.UpdateServiceIntegration(idRowSIC, "Elaborato");

                            #region Innesco CreaScheda SC1
                            DatiScheda datiScheda = pu.getDatiScheda(idRow);
                            TipoScheda tipoSchedaGaraSC_CONF = pu.recuperaTipoSchedaGara(datiScheda.idgara);
                            var listOfSchedePreS3 = pu.recuperaListaSchedePreS3();
                            //SE SI TRATTA DI UNA GARA P1_16, P2_16, AD3, AD5, AD2_25, P7.1_2 e sto completando l'A1_29 da una CONVENZIONE allora 
                            if (
                                listOfSchedePreS3.Contains(tipoSchedaGaraSC_CONF) &&
                                pu.enumTipoScheda(datiScheda.tipoScheda) == TipoScheda.A1_29 &&
                                datiScheda.TipoDoc_IdDoc_Scheda.ToUpper() == "CONVENZIONE")
                            {
                                //avvio una richiesta di creazione Scheda SC_1 passando come IdDoc_Scheda l'id della convenzione
                                pu.avviaSentinellaRichiestaScheda(idRic: datiScheda.idgara, idpfu, tipoScheda: "SC1", operazioneRichiesta: "CreaScheda", datiScheda.IdDoc_Scheda);
                            }
                            #endregion
                            #region Innesco S3
                            if (
                                listOfSchedePreS3.Contains(tipoSchedaGaraSC_CONF) &&
                                pu.enumTipoScheda(datiScheda.tipoScheda) == TipoScheda.SC1 &&
                                (datiScheda.TipoDoc_IdDoc_Scheda.ToUpper() == "SCRITTURA_PRIVATA" || datiScheda.TipoDoc_IdDoc_Scheda.ToUpper() == "CONVENZIONE"  || datiScheda.TipoDoc_IdDoc_Scheda.ToUpper() == "CONTRATTO_GARA_FORN")
                                ) 
                            {
                                //avvio una richiesta di creazione Scheda S3 passando come IdDoc_Scheda l'id della convenzione
                                pu.avviaSentinellaRichiestaScheda(idRic: datiScheda.idgara, idpfu, tipoScheda: "S3", operazioneRichiesta: "CreaScheda", datiScheda.IdDoc_Scheda);
                            }
                            #endregion
                            
                            break;

                        case ("AV_PUBB"):

                            pu.inserisciLogIntegrazione(iddoc, "esito-operazione", statoRichiestaLog, pu.recuperaTipoSchedaGara(iddoc), "idAppalto", "", endpointWithQS, result, DateTime.Now, DateTime.Now, DateTime.Now, idpfu, dati.idAzi, "OUT");

                            pu.UpdateServiceIntegration(idRowSIC, "Elaborato");
                            break;
                        default:
                            break;
                    }


                }
                else
                {
                    errorMaxRetry = manageErrorAndRetry(idRowSIC, iddoc, idpfu, idRow, statoEsitoOperazione, tipoOperazione, messaggioEsito, endpointWithQS, result, dati, tipoScheda);

                    //Faccio risalire un errore solo se ho superato il max retry, altrimenti diamo ok e continuiamo con i tentativi
                    if (errorMaxRetry)
                    {
                        if (string.IsNullOrEmpty(messaggioEsito))
                            throw new ApplicationException("l'operazione esito-operazione non è stata eseguita correttamente");

                        throw new ApplicationException($"Errore da esito-operazione : {messaggioEsito}");
                    }
                    
                    //se non ho superato il max retry do un ok 
                    esito = "1#RETRY";
                }
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


            try
            {
                //Se ho avuto eccezione per un motivo qualsiasi ( cioè passo da uno dei catch )
                if (esito.StartsWith("0#"))
                {
                    strCause = "Inserimento trace di errore";
                    pu.InsertTrace("PCP",$"Errore nel metodo di esitoOperazione : {esito}", iddoc);

                    //Se c'è stato un errore non previsto passiamo comunque dalla gestione del retry automatico a meno che non si sia giù superata la soglia di retry
                    if (!errorMaxRetry)
                    {
                        strCause = "Invocazione manageErrorAndRetry per gestione Exception";
                        errorMaxRetry = manageErrorAndRetry(idRowSIC, iddoc, idpfu, idRow, statoEsitoOperazione,
                            tipoOperazione, messaggioEsito, endpointWithQS, result, dati, tipoScheda);

                        if (!errorMaxRetry)
                        {
                            //se non ho superato il max retry do un ok anche se avevo un errore. se invece si è raggiunto il max retry lasciamo risalire l'errore "originale"
                            esito = "1#RETRY";
                        }
                    }
                    
                }
            }
            catch (Exception e)
            {
                esito += strCause + " -- " + e.ToString();
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

        private bool manageErrorAndRetry(int idRowSIC, int iddoc, int idpfu, int idRow, string statoEsitoOperazione, string tipoOperazione, string messaggioEsito, string endpointWithQS, string rispostaJson, Dati_PCP dati, TipoScheda? tipoScheda)
        {
            PDNDUtils pu = new PDNDUtils();
            bool superatoMaxRetry = false;
            string statoRichiestaLog = "Errore";

            //Se lo stato restituito dall'anac è di attesa allora il log non deve entrare come "Errore", la richiesta infatti è andata bene, dobbiamo soltanto riprovare con un delay
            if (statoEsitoOperazione == "AP_IN_CONF" || statoEsitoOperazione == "SC_IN_CONF" ||
                statoEsitoOperazione == "AV_IN_PUBB")
            {
                statoRichiestaLog = "Elaborato";
            }

            if (messaggioEsito == "1#OK" )
                messaggioEsito = "";

            messaggioEsito = messaggioEsito.Replace("0#", "");

            int numRetry = pu.GetNumRetrySIC(idRowSIC);

            //dal Web.Config cerco di recuperare i valori se sono stati settati, in caso contrario applico il default (specifico per ogni case dello switch)
            long delay = Convert.ToInt64(ConfigurationManager.AppSettings[$"PCP.EsitoOperazione.Delay.{tipoOperazione}"] ?? "-1");
            long numRetryLimit = Convert.ToInt64(ConfigurationManager.AppSettings[$"PCP.EsitoOperazione.NumRetryLimit.{tipoOperazione}"] ?? "-1");

            switch (tipoOperazione)
            {
                //case ("AP_IN_CONF"):
                case ("AP_CONF"):

                    pu.inserisciLogIntegrazione(iddoc, "esito-operazione", statoRichiestaLog, pu.recuperaTipoSchedaGara(iddoc),
                        "idAppalto", messaggioEsito, endpointWithQS, rispostaJson, DateTime.Now, DateTime.Now,
                        DateTime.Now, idpfu, dati.idAzi, "OUT");

                    //se APPALTO NON CONFERMATO NON RIPROVO
                    if ( statoEsitoOperazione  != "AP_N_CONF")
					{
						//crea/conferma appalto -> default: ogni 10 min per un massimo di 10 volte
						//  ---> sposto da 10 minuti a 30 perchè su puglia dopo 4 ore la conferma-appalto ancora non era stata chiusa
						numRetryLimit = numRetryLimit == -1 ? 10 : numRetryLimit;
						if (numRetry >= numRetryLimit)
						{
							superatoMaxRetry = true;
							pu.UpdateServiceIntegration(idRowSIC, "Errore");
							pu.ScheduleProcess(idRowSIC, DateTime.Now, "PCP_ESITO_OPERAZIONE", "SEND_MAIL_RUP");
							//Evidenziamo il superamento del maxRetry con uno stato dedicato
							pu.aggiornaRecordSchedaAppalto(iddoc, idpfu, pu.traduciTipoScheda(tipoScheda), "AP_CONF_MAX_RETRY");
						}
						else
						{

							//se NON ho avuto uno status di risposta da ANC
							if (string.IsNullOrEmpty(statoEsitoOperazione))
							{
								pu.aggiornaRecordSchedaAppalto(iddoc, idpfu, pu.traduciTipoScheda(tipoScheda), "AP_CONF_NO_ESITO");
							}

							pu.UpdateServiceIntegration(idRowSIC, statoRichiestaLog, numRetry + 1);
							DateTime timeDelay = delay == -1 ? DateTime.Now.AddMinutes(30) : DateTime.Now.AddSeconds(delay);
							pu.ScheduleProcess(idRowSIC, timeDelay);
						}
					}
                    else
					{
						pu.UpdateServiceIntegration(idRowSIC, "Errore"); 
					}

					break;

                //case ("SC_IN_CONF"):
                case ("SC_CONF"):

                    pu.inserisciLogIntegrazione(iddoc, "esito-operazione", statoRichiestaLog, pu.recuperaTipoScheda(idRow),
                        tipoOperazione, messaggioEsito, endpointWithQS, rispostaJson, DateTime.Now, DateTime.Now,
                        DateTime.Now, idpfu, dati.idAzi, "OUT");

                    //se scheda NON CONFERMATA NON RIPROVO
					if (statoEsitoOperazione != "SC_N_CONF")
					{
						//crea/conferma scheda -> default: ogni 10 min per un massimo di 10 volte
						numRetryLimit = numRetryLimit == -1 ? 10 : numRetryLimit;
                        if (numRetry >= numRetryLimit)
                        {
                            superatoMaxRetry = true;
                            pu.UpdateServiceIntegration(idRowSIC, "Errore");
                            //Passiamo idpfu a -10 ( il default è -20 ) perchè il processo deve discriminare se l'idRichiesta è l'idrow della tabella delle schede o l'id della gara
                            pu.ScheduleProcess(idRowSIC, DateTime.Now, "PCP_ESITO_OPERAZIONE", "SEND_MAIL_RUP", "-10");
                            //Evidenziamo il superamento del maxRetry con uno stato dedicato
                            pu.aggiornaScheda(idRow, "SC_CONF_MAX_RETRY");
                        }
                        else
                        {
                            //se NON ho avuto uno status di risposta da ANC
                            if (string.IsNullOrEmpty(statoEsitoOperazione))
                            {
                                pu.aggiornaScheda(idRow, "SC_CONF_NO_ESITO");
                            }

                            pu.UpdateServiceIntegration(idRowSIC, statoRichiestaLog, numRetry + 1);
                            DateTime timeDelay = delay == -1 ? DateTime.Now.AddMinutes(30) : DateTime.Now.AddSeconds(delay);
                            pu.ScheduleProcess(idRowSIC, timeDelay);
                        }
					}
					else
					{
						pu.UpdateServiceIntegration(idRowSIC, "Errore");
					}

					break;

                //case ("AV_IN_PUBB"):
                case ("AV_PUBB"):

                    pu.inserisciLogIntegrazione(iddoc, "esito-operazione", statoRichiestaLog, pu.recuperaTipoSchedaGara(iddoc),
                        "idAppalto", messaggioEsito, endpointWithQS, rispostaJson, DateTime.Now, DateTime.Now,
                        DateTime.Now, idpfu, dati.idAzi, "OUT");

					//se AVVISO NON PUBBLICATO NON RIPROVO
					if (statoEsitoOperazione != "AV_N_PUBB")
					{
						//pubblica avviso -> default: ogni 2 ore per 20 volte
						numRetryLimit = numRetryLimit == -1 ? 20 : numRetryLimit;
                        if (numRetry >= numRetryLimit)
                        {
                            superatoMaxRetry = true;
                            pu.UpdateServiceIntegration(idRowSIC, "Errore");
                            pu.ScheduleProcess(idRowSIC, DateTime.Now, "PCP_ESITO_OPERAZIONE", "SEND_MAIL_RUP");
                            //Evidenziamo il superamento del maxRetry con uno stato dedicato
                            pu.aggiornaRecordSchedaAppalto(iddoc, idpfu, pu.traduciTipoScheda(tipoScheda), "AV_PUBB_MAX_RETRY");
                        }
                        else
                        {
                            //se NON ho avuto uno status di risposta da ANC
                            if (string.IsNullOrEmpty(statoEsitoOperazione))
                            {
                                pu.aggiornaRecordSchedaAppalto(iddoc, idpfu, pu.traduciTipoScheda(tipoScheda), "AV_PUBB_NO_ESITO");
                            }

                            pu.UpdateServiceIntegration(idRowSIC, statoRichiestaLog, numRetry + 1);
                            DateTime timeDelay = delay == -1 ? DateTime.Now.AddHours(2) : DateTime.Now.AddSeconds(delay);
                            pu.ScheduleProcess(idRowSIC, timeDelay);
                        }
					}
					else
					{
						pu.UpdateServiceIntegration(idRowSIC, "Errore");
					}

					break;

                default:
                    //Tipo Operazione non gestito, metto la sentinella a "Errore" così non creo un loop
                    pu.UpdateServiceIntegration(idRowSIC, "Errore");
                    break;
            }

            return superatoMaxRetry;

        }
    }
}
