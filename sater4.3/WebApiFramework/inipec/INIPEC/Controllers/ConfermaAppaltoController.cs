using INIPEC.Library;
using INIPEC.Library.DTO;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;
using System.Web.Http;
using System.Web.Http.Results;

namespace INIPEC.Controllers
{
    public class ConfermaAppaltoController : ApiController
    {

        //private static readonly string BasePath = AppDomain.CurrentDomain.BaseDirectory;


        [ActionName("confermaAppalto")]
        public HttpResponseMessage confermaAppalto(int idDoc, int idpfu, string idAppalto)
        {
            string esito = "1#OK";
            string strCause = "confermaAppalto - START";

            TipoScheda? tipoScheda = null;
            PDNDUtils pu = new PDNDUtils();
            bool traceError = true;

            try
            {

                strCause = "Recupero il tipo scheda";
                tipoScheda = pu.recuperaTipoSchedaGara(idDoc);

                strCause = "confermaAppalto - start recuperaDatiPerVoucher";

                Dati_PCP dati = pu.recuperaDatiPerVoucher(idDoc, "Comunica appalto", "/cancella-appalto");

                string json = JsonSerializer.Serialize(new IdAppalto { idAppalto = idAppalto });


                strCause = "confermaAppalto - start recuperaMetodoDaServizio";
                HttpMethod method = pu.recuperaMetodoDaServizio("/conferma-appalto");

                string endpointContesto = dati.aud;
                string endpointContestuale = $"{endpointContesto}/conferma-appalto";

                strCause = "Chiamata alla Get Barer Token";
                var objVoucher = pu.GetBarerToken(dati, idDoc);

                strCause = "confermaAppalto - start get or post /conferma-appalto verso ANAC";
                string result = string.Empty;
                if (method == HttpMethod.Get)
                {
                    Dictionary<string, string> data = new Dictionary<string, string>
                    {
                        { "idAppalto", idAppalto }
                    };
                    result = pu.sendRequest(objVoucher.client, endpointContestuale, "", objVoucher.voucher, objVoucher.jwtWithData, method, parametri: data, idDoc: idDoc);
                }
                else if (method == HttpMethod.Post)
                {
                    result = pu.postRequest(objVoucher.client, endpointContestuale, "", objVoucher.voucher, objVoucher.jwtWithData, method, body: json, idDoc: idDoc);
                }


                strCause = "Deserialize della risposta di anac";
                RispostaServizi risposta = JsonSerializer.Deserialize<RispostaServizi>(result);

                if (risposta.status == 200)
                {
                    //Se ho un 200 loggo la risposta e creo una sentinella verso la pagina /Application/PCP/PCP_ServiziComuni.asp
                    //che si occupera di chiamare in modo ASINCRONO l'endpoint /esito-operazione

                    strCause = "Inserimento log di conferma positiva";
                    pu.inserisciLogIntegrazione(idDoc, "conferma-appalto", "Elaborato", tipoScheda, "idAppalto", "", json, result, DateTime.Now, DateTime.Now, DateTime.Now, idpfu, dati.idAzi, "OUT");

                    strCause = "Passo stato della scheda appalto a Confermato";
                    pu.aggiornaRecordSchedaAppalto(idDoc, idpfu, pu.traduciTipoScheda(tipoScheda), "Confermato");

                    strCause = "Richiedo una sentinella di esito operazione su conferma-appalto";
                    pu.avviaEsitoOperazione(idpfu, idDoc, "conferma-appalto");

                }
                else
                {
                    //Se non ho un 200 loggo la chiamata con l'errore e faccio risalire l'errore a video
                    pu.inserisciLogIntegrazione(idDoc, "conferma-appalto", "Errore", pu.recuperaTipoSchedaGara(idDoc), "idAppalto", risposta.detail, json, result, DateTime.Now, DateTime.Now, DateTime.Now, idpfu, dati.idAzi, "OUT");
                    traceError = false;
                    throw new ApplicationException($"L'operazione conferma-appalto non è stata eseguita correttamente");
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
                //Se ho avuto eccezione per un motivo qualsiasi ( cioè passo da uno dei catch ) passo lo stato della scheda ad errore
                if (esito.StartsWith("0#"))
                {
                    strCause = "Inserimento trace di errore";
                    pu.InsertTrace("PCP", $"Errore nel metodo di creaAppalto : {esito}", idDoc);

                    //Traccio nel log l'errore solo se non è stato gestito in precedenza
                    if (traceError)
                    {
                        try
                        {
                            pu.inserisciLogIntegrazione(idDoc, "conferma-appalto", "Errore", pu.recuperaTipoSchedaGara(idDoc), "idAppalto", esito, "", "", DateTime.Now, DateTime.Now, DateTime.Now, idpfu, 0, "OUT");
                        }
                        catch
                        {
                        }
                    }

                    if (tipoScheda != null)
                    {
                        strCause = "Passo lo stato scheda a ErroreConferma";
                        pu.aggiornaRecordSchedaAppalto(idDoc, idpfu, pu.traduciTipoScheda(tipoScheda), "ErroreConferma");
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

        /// <summary>
        /// /api/ConfermaAppalto/creaAppalto
        /// </summary>
        /// <param name="iddoc"></param>
        /// <param name="idpfu"></param>
        /// <returns>1#OK or 0#Error</returns>
        [HttpGet]
        [ActionName("creaAppalto")]
        public HttpResponseMessage creaAppalto(int iddoc = -20, int idpfu = -20)
        {
            string esito = "1#OK";
            string strCause = "creaAppalto - START";
            int idRowScheda = 0;
            bool traceError = true;
            PDNDUtils pu = new PDNDUtils();
            TipoScheda? tipoScheda = null;

            try
            {
                strCause = "Recupero tipo scheda gara";
                tipoScheda = pu.recuperaTipoSchedaGara(iddoc);

                strCause = "Creazione record per stato appalto";
                idRowScheda = pu.creaRecordSchedaAppalto(iddoc, idpfu, pu.traduciTipoScheda(tipoScheda));

                string eformXml64 = "";
                string espdXml64 = "";

                strCause = "Recupero eform ed espd";
                pu.RecuperaEFormXml64EspdXml64(iddoc, ref eformXml64, ref espdXml64);

                strCause = "creaAppalto - start recuperaDatiPerVoucher";

                //TODO: passa creaAppalto
                Dati_PCP dati = pu.recuperaDatiPerVoucher(iddoc);

                strCause = "creaAppalto - start compilaScheda";
                object s = pu.compilaScheda(iddoc, eformXml64, espdXml64, dati, (TipoScheda)tipoScheda);

                string json = "";
                switch (tipoScheda)
                {
                    case TipoScheda.P1_16:
                        BaseModel basemodelP1_16 = new BaseModel();
                        basemodelP1_16.scheda = (Scheda)s;
                        //json = JsonSerializer.Serialize(basemodelP1_16);
                        json = AnacFormUtils.getJsonWithOptAttrib(basemodelP1_16);

                        break;
                    case TipoScheda.P2_16:
                        BaseModelP2_16 baseModelP2_16 = new BaseModelP2_16();
                        baseModelP2_16.scheda = (SchedaP2_16)s;
                        //json = JsonSerializer.Serialize(baseModelP2_16);
                        json = AnacFormUtils.getJsonWithOptAttrib(baseModelP2_16);
                        break;
                    case TipoScheda.P2_20:
                        BaseModelP2_20 baseModelP2_20 = new BaseModelP2_20();
                        baseModelP2_20.scheda = (SchedaP2_20)s;

                        json = AnacFormUtils.getJsonWithOptAttrib(baseModelP2_20);
                        break;
                    case TipoScheda.P1_20:
                        BaseModelP1_20 baseModelP1_20 = new BaseModelP1_20();
                        baseModelP1_20.scheda = (SchedaP1_20)s;

                        json = AnacFormUtils.getJsonWithOptAttrib(baseModelP1_20);
                        break;                        
                    case TipoScheda.AD_3:
                    case TipoScheda.AD_5:
                        BaseModelAD3 basemodelAD_3 = new BaseModelAD3();
                        basemodelAD_3.scheda = (SchedaAD3)s;
                        //json = JsonSerializer.Serialize(basemodelAD_3);
                        json = AnacFormUtils.getJsonWithOptAttrib(basemodelAD_3);

                        break;
                    case TipoScheda.AD2_25:
                        BaseModelAD2_25 baseModelAD2_25 = new BaseModelAD2_25();
                        baseModelAD2_25.scheda = (SchedaAd2_25)s;

						//json = JsonSerializer.Serialize(baseModelAD2_25);
						json = AnacFormUtils.getJsonWithOptAttrib(baseModelAD2_25);

						break;
                    case TipoScheda.P7_2:
                        var baseModelP7_2 = new BaseModelP7_2();
                        baseModelP7_2.scheda = (SchedaP7_2)s;
                        //json = JsonSerializer.Serialize(baseModelP7_2);
                        json = AnacFormUtils.getJsonWithOptAttrib(baseModelP7_2);

                        break;
                    case TipoScheda.P7_1_2:
                        BaseModelP7_1_2 baseModelP7_1_2 = new BaseModelP7_1_2();
                        baseModelP7_1_2.scheda = (SchedaP7_1_2)s;
                        //json = JsonSerializer.Serialize(baseModelP7_1_2);
                        json = AnacFormUtils.getJsonWithOptAttrib(baseModelP7_1_2);
                        break;
                    case TipoScheda.P7_1_3:
                        BaseModelP7_1_3 baseModelP7_1_3 = new BaseModelP7_1_3();
                        baseModelP7_1_3.scheda = (SchedaP7_1_3)s;
                        //json = JsonSerializer.Serialize(baseModelP7_1_2);
                        json = AnacFormUtils.getJsonWithOptAttrib(baseModelP7_1_3);
                        break;
                    case TipoScheda.P1_19:
                        BaseModelP1_19 baseModelP1_19 = new BaseModelP1_19();
                        baseModelP1_19.scheda = (SchedaP1_19)s;

                        json = AnacFormUtils.getJsonWithOptAttrib(baseModelP1_19);
                        break;
                    case TipoScheda.P2_19:
                        BaseModelP2_19 baseModelP2_19 = new BaseModelP2_19();
                        baseModelP2_19.scheda = (SchedaP2_19)s;

                        json = AnacFormUtils.getJsonWithOptAttrib(baseModelP2_19);
                        break;

					case TipoScheda.AD_4:
						BaseModelAD4 basemodelAD_4 = new BaseModelAD4();
						basemodelAD_4.scheda = (SchedaAD4)s;
						json = AnacFormUtils.getJsonWithOptAttrib(basemodelAD_4);

						break;

                    case TipoScheda.A3_6:
                        BaseModelA3_6 baseModelA3_6 = new BaseModelA3_6();
                        baseModelA3_6.scheda = (SchedaA3_6)s;
                        json = AnacFormUtils.getJsonWithOptAttrib(baseModelA3_6);

                        break;
                    default:
                        break;
                }

                //#if DEBUG
                //System.IO.File.WriteAllText(@"c:\temp\esitoPCP.json", json);
                //#endif


                strCause = "creaAppalto - start recuperaMetodoDaServizio";

                //Ogni servizio (endpoint) ha un metodo associato, lo recupero da db
                HttpMethod method = pu.recuperaMetodoDaServizio("/crea-appalto");

                string endpointContesto = dati.aud;
                string endpointContestuale = $"{endpointContesto}/crea-appalto";

                string result = string.Empty;

                if (method == HttpMethod.Post)
                {
                    strCause = "Chiamata alla Get Barer Token";
                    var objVoucher = pu.GetBarerToken(dati, iddoc);

                    //chiamata effettiva verso ANAC /crea-appalto
                    strCause = "Chiamata al ws di crea-appalto";
                    result = pu.postRequest(objVoucher.client, endpointContestuale, "", objVoucher.voucher, objVoucher.jwtWithData, method, body: json, idDoc: iddoc);
                }
                else
                {
                    throw new NotImplementedException();
                }

                strCause = "Deserialize della risposta anac";
                RispostaCreaAppalto risposta = JsonSerializer.Deserialize<RispostaCreaAppalto>(result);
                //string rispostaJson = JsonSerializer.Serialize(risposta);
                if (risposta.status == 200)
                {
                    //se ho un 200 da ANAC dopo la chiamata POST /crea-appalto mi devo salvare l'idAppalto
                    //che mi ha restituito la chiamata nella tabella Document_PCP_Appalto, colonna pcp_CodiceAppalto,
                    //in modo sincrono vado subito sulla /conferma-appalto (richiamo direttamente l'altra action nello stesso controller)
                    string idAppalto = risposta.idAppalto;

                    if (string.IsNullOrEmpty(idAppalto))
                        throw new ApplicationException("idAppalto vuoto nella risposta postiva da anac");

                    pu.AggiornaIdAppalto(iddoc, idAppalto);
                    pu.inserisciLogIntegrazione(iddoc, "crea-appalto", "Elaborato", pu.recuperaTipoSchedaGara(iddoc), "idAppalto", "", json, result, DateTime.Now, DateTime.Now, DateTime.Now, idpfu, dati.idAzi, "OUT");

                    strCause = "Passo stato della scheda appalto a Creato";
                    pu.aggiornaRecordSchedaAppalto(iddoc, idpfu, pu.traduciTipoScheda(tipoScheda), "Creato", idRowScheda);

                    ConfermaAppaltoController confermaAppaltoController = new ConfermaAppaltoController();
                    return confermaAppaltoController.confermaAppalto(iddoc, idpfu, idAppalto);
                }
                else
                {
                    pu.InsertTrace("PCP", "Errore dal crea-appalto. per il dettaglio vedere la Services_Integration_Request", iddoc);
                    pu.inserisciLogIntegrazione(iddoc, "crea-appalto", "Errore", pu.recuperaTipoSchedaGara(iddoc), "idAppalto", risposta.detail, json, result, DateTime.Now, DateTime.Now, DateTime.Now, idpfu, dati.idAzi, "OUT");
                    traceError = false; //Avendo tracciato qui l'errore, comprensivo di dettaglio lato anac, non faccio inserire la traccia anche dopo il lancio dell'exception

                    throw new ApplicationException("l'operazione crea-appalto non è stata eseguita correttamente");
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
			finally
			{
				try
				{
					//Se ho avuto eccezione per un motivo qualsiasi ( cioè passo da uno dei catch ) passo lo stato della scheda ad errore ed inserirco un log di Errore in cronologia
					if (esito.StartsWith("0#"))
					{
						strCause = "Inserimento trace di errore";
						pu.InsertTrace("PCP", $"Errore nel metodo di creaAppalto : {esito}", iddoc);

						if (traceError)
						{
							try
							{
								pu.inserisciLogIntegrazione(iddoc, "crea-appalto", "Errore",
									pu.recuperaTipoSchedaGara(iddoc), "idAppalto", esito, "", "", DateTime.Now,
									DateTime.Now, DateTime.Now, idpfu, 0, "OUT");
							}
							catch
							{
							}
						}

						if (tipoScheda != null && idRowScheda > 0)
						{
							strCause = "Passo lo stato scheda a ErroreCreazione";
							pu.aggiornaRecordSchedaAppalto(iddoc, idpfu, pu.traduciTipoScheda(tipoScheda), "ErroreCreazione", idRowScheda);
						}

					}
				}
				catch (Exception e)
				{
					esito += strCause + " -- " + e.ToString();
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
        [ActionName("recuperaCig")]
        public HttpResponseMessage recuperaCig(int iddoc = -20, int idpfu = -20, string idAppalto = "", int page = 0, int perPage = 0)
        {
            string esito = "1#OK";
            string strCause = "recuperaCig - START";

            PDNDUtils pu = new PDNDUtils();
            TipoScheda? tipoScheda = null;
            bool traceError = true;

            string TipoDocGara = "";

            try
            {
                tipoScheda = pu.recuperaTipoSchedaGara(iddoc);

                //recupero il tipodo dalla ctl_doc mi serve per aggiornare i cig sui dettagli
                TipoDocGara = pu.recuperaTipoDocGara(iddoc);

				Dati_PCP dati = pu.recuperaDatiPerVoucher(iddoc);

                bool bGaraMultilotto;

                //SE SONO SUGLI ORDINATIVI DI FORNITURA O DI ACQUISTO SONO MONOLOTTO
                if (TipoDocGara.ToUpper() == "ODC" || TipoDocGara.ToUpper() == "ODA")
				{
					bGaraMultilotto = false;
				}
				else
                {
                    //determino se gara monolotto/lotti
                    bGaraMultilotto = pu.garaIsMultiLotto(iddoc);
                }

				HttpMethod method = pu.recuperaMetodoDaServizio("/recupera-cig");

                string endpointContesto = dati.aud;
                string endpointContestuale = $"{endpointContesto}/recupera-cig";

                string result = string.Empty;

                if (method == HttpMethod.Get)
                {
                    Dictionary<string, string> data = new Dictionary<string, string>();

                    data.Add("idAppalto", idAppalto);

                    page = 1;
                    perPage = 20;

                    //DETERMINO LA PAGINA CORRENTE DA CHIAMARE SE SI TRATTA DI GARA A LOTTI
                    if (bGaraMultilotto)
                    {
                        page = pu.GetNextPage_For_RecuperaCIg(iddoc, perPage, TipoDocGara);
                    }

                    //se non vi sono cig da recuperare devo uscire con esito positivo
                    //questa cosa serve se si reinnesca per errore per un debug su una gara con cig già recuperati
                    //ritornava sempre pagina 1

                    if (page == 0)
                    {
                        return new HttpResponseMessage()
                        {
                            Content = new StringContent(
                                esito,
                                Encoding.UTF8,
                                "text/html"
                            )
                        };
                    }


                    strCause = "Chiamata alla Get Barer Token";
                    var objVoucher = pu.GetBarerToken(dati, iddoc);

                    if (objVoucher == null || string.IsNullOrEmpty(objVoucher.voucher))
                        throw new ApplicationException("Fallita la generazione del voucher");

                    data.Add("page", page.ToString());
                    data.Add("perPage", perPage.ToString());

                    result = pu.sendRequest(objVoucher.client, endpointContestuale, "", objVoucher.voucher, objVoucher.jwtWithData, method, parametri: data, idDoc: iddoc);
                }
                else if (method == HttpMethod.Post)
                {
                    throw new NotImplementedException();
                }

                string endpointWithQS = endpointContestuale + "?idAppalto=" + idAppalto + "&page=" + page + "&perPage=" + perPage;
                string rispostaJson = string.Empty;
                RispostaCig risposta = JsonSerializer.Deserialize<RispostaCig>(result);

                if (risposta.status == 200) // && risposta.title.ToUpper() == "OK")
                {
                    List<Tipologica> rCig = risposta.result;
                    if (!bGaraMultilotto)
                    {
                        string cig = rCig[0].cig;
                        
                        //CONTROLLO SE CIG VALORIZZATO: se non lo è ritorno una eccezione e la scrivo nel log e mi fermo
                        if (!string.IsNullOrEmpty(cig) )
						{
							pu.aggiornaCigMonolotto(iddoc, cig, TipoDocGara);
						}
                        else
						{
                            //genero una eccezione applicativa
                            throw new DataMisalignedException("Cig ritornato vuoto da ANAC");
						}
				    }
                    else
                    {
                        foreach (Tipologica valCIG in rCig)
                        {
                            string lotto = valCIG.lotIdentifier;
                            string cig = valCIG.cig;

							//CONTROLLO SE CIG VALORIZZATO: se non lo è ritorno una eccezione e la scrivo nel log e mi fermo
							if (!string.IsNullOrEmpty(cig))
							{
								int idLotto = Convert.ToInt32(Regex.Match(lotto, @"\d+").Value);
                                rispostaJson = JsonSerializer.Serialize(risposta);
                                pu.aggiornaCigP1_16(iddoc, cig, idLotto, TipoDocGara);
							}
							else
							{
								//genero una eccezione applicativa
								throw new DataMisalignedException($"Cig ritornato vuoto da ANAC lotto={lotto}");
							}

						}

                    }

                    pu.inserisciLogIntegrazione(iddoc, "recupera-cig", "Elaborato", tipoScheda, "CIG", "", endpointWithQS, result, DateTime.Now, DateTime.Now, DateTime.Now, idpfu, dati.idAzi, "OUT");

                    //se ho più di una pagina (nell'esito ho totPages ) e nopn sono arrivato all'ultima pagina allora devo fare l achiamta per la prossima pagina
                    //schedulata con un delay di 10 secondi
                    int nTotPages = risposta.totPages;

                    if (nTotPages > 1 && nTotPages > page)
                    {

						//PRIMA DI SCHEDULARE UN'ALTRA CHIAMATA VEDO SE HO RAGGIUNTO UN LIMITE MASSIMO DI CHIAMATE (200)
                        //COME LIMITE SUPERIORE PER EVITARE UN LOOP
						//int numRetry = pu.GetNumRetrySIC(idRowSIC);
                        

						//SCHEDULO LA CHIAMATA AL PROCESSO RECUPERO CIG PER LA STESSA GARA PER LA PAGINA SUCCESSIVA
						pu.ScheduleProcess(iddoc, DateTime.Now.AddSeconds(10), "BANDO_GARA", "PCP_RecuperaCig_Next");
                    }
                    else
                    {
                        //Se non ho più niente da recuperare allora posso cambiare lo stato della scheda/appalto in "cig recuperati"
                        pu.aggiornaRecordSchedaAppalto(iddoc, idpfu, pu.traduciTipoScheda(tipoScheda), "CigRecuperati");
                    }

                }
                else
                {
                    pu.inserisciLogIntegrazione(iddoc, "recupera-cig", "Errore", tipoScheda, "CIG", risposta.detail, endpointWithQS, result, DateTime.Now, DateTime.Now, DateTime.Now, idpfu, dati.idAzi, "OUT");
                    traceError = false;
                    throw new ApplicationException("l'operazione recupera-cig non è stata eseguita correttamente");
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
			catch (DataMisalignedException e)
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
                //Se ho avuto eccezione per un motivo qualsiasi ( cioè passo da uno dei catch ) passo lo stato della scheda ad errore
                if (esito.StartsWith("0#"))
                {

                    strCause = "Inserimento trace di errore";
                    pu.InsertTrace("PCP", $"Errore nel metodo di recuperaCig : {esito}", iddoc);

                    //Traccio nel log l'errore solo se non è stato gestito in precedenza
                    if (traceError)
                    {
                        try
                        {
                            pu.inserisciLogIntegrazione(iddoc, "recupera-cig", "Errore", tipoScheda, "CIG", esito, "", "", DateTime.Now, DateTime.Now, DateTime.Now, idpfu, 0, "OUT");
                        }
                        catch
                        {
                        }
                    }

                    if (tipoScheda != null)
                    {
                        strCause = "Passo lo stato scheda a ErroreConferma";
                        pu.aggiornaRecordSchedaAppalto(iddoc, idpfu, pu.traduciTipoScheda(tipoScheda), "ErroreCigRecuperati");
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

        /// <summary>
        /// Recupera il centro di costo fornito un iddoc sulla base del codice AUSA
        /// </summary>
        /// <param name="iddoc"></param>
        /// <param name="tipoEnte"></param>
        /// <returns>1#Codice or 0#Errore</returns>
        [HttpGet]
        [ActionName("recuperaCDC")]
        public HttpResponseMessage recuperaCDC(int iddoc)
        {
            string esito = "1#OK";
            string strCause = "recuperaCDC - START";

            bool traceError = true;
            PDNDUtils pu = new PDNDUtils();

            try
            {

                strCause = "recuperaDatiPerVoucher";
                Dati_PCP dati = pu.recuperaDatiPerVoucher(iddoc, "AUSA", "/api/ausa/getBy");

                HttpMethod method = pu.recuperaMetodoDaServizio("/api/ausa/getBy");

                string endpointContesto = dati.aud;
                string endpointContestuale = $"{endpointContesto}/api/ausa/getBy";

                string result = string.Empty;
                string codiceAusa = dati.codiceAUSA;

                strCause = "Chiamata alla Get Barer Token";
                var objVoucher = pu.GetBarerToken(dati, iddoc);

                if (method == HttpMethod.Get)
                {
                    Dictionary<string, string> data = new Dictionary<string, string>();
                    data.Add("codiceAusa", codiceAusa);
                    // "https://apigw-test.anticorruzione.it/modi/rest/AUSA/v1/api/ausa/getBy?codiceAusa=9000000006"
                    // "https://apigw-test.anticorruzione.it/modi/rest/AUSA/v1/api

                    strCause = "sendRequest";
                    result = pu.sendRequest(objVoucher.client, endpointContestuale, "", objVoucher.voucher, objVoucher.jwtWithData, method, parametri: data, idDoc: iddoc);
                }
                else
                {
                    throw new NotImplementedException();
                }


                string endpointWithQS = endpointContestuale + "?codiceAusa=" + codiceAusa;

                strCause = "Deserialize della risposta";
                RispostaAusaCDC risposta = JsonSerializer.Deserialize<RispostaAusaCDC>(result);
                string errore = "";
                List<CentroDiCostoLight> listcdc = new List<CentroDiCostoLight>();

                try
                {
                    strCause = "Iteriamo sui centri di costo";
                    foreach (var item in risposta.items[0].scheda.stazioneAppaltante.centriDiCosto)
                    {
                        CentroDiCostoLight cdcl = new CentroDiCostoLight();
                        cdcl.idCentroDiCosto = item.idCentroDiCosto;
                        cdcl.denominazioneCentroDiCosto = item.denominazioneCentroDiCosto;
                        if (item.stato.stato != null && item.stato.stato.ToUpper() == "ATTIVO")
                        {
                            listcdc.Add(cdcl);
                        }
                    }

                }
                catch (Exception ex)
                {
                    errore = $"Impossibile recuperare il Codice Centro di Costo : {ex.Message}";
                }

                strCause = "Test della risposta";
                if (risposta.code == 200 && errore == "" && listcdc.Count > 0)
                {
                    //pu.inserisciLogIntegrazione(iddoc, "recuperaCDC", "Elaborato", pu.recuperaTipoSchedaGara(iddoc), "CDC", "", endpointWithQS, result, DateTime.Now, DateTime.Now, DateTime.Now, -20, dati.idAzi, "OUT");
                    esito = JsonSerializer.Serialize<List<CentroDiCostoLight>>(listcdc);
                }
                else
                {
                    pu.inserisciLogIntegrazione(iddoc, "recuperaCDC", "Errore", pu.recuperaTipoSchedaGara(iddoc), "CDC", risposta.title, endpointWithQS, result, DateTime.Now, DateTime.Now, DateTime.Now, -20, dati.idAzi, "OUT");
                    traceError = false;
                    throw new ApplicationException("l'operazione recuperaCDC non ha restituito un codice 200 - " + risposta.title);
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
                //Se ho avuto eccezione per un motivo qualsiasi ( cioè passo da uno dei catch ) passo lo stato della scheda ad errore ed inserirco un log di Errore in cronologia
                if (esito.StartsWith("0#"))
                {
                    strCause = "Inserimento trace di errore";
                    pu.InsertTrace("PCP", $"Errore nel metodo di recuperaCDC : {esito}", iddoc);

                    if (traceError)
                    {
                        try
                        {
                            pu.inserisciLogIntegrazione(iddoc, "recuperaCDC", "Errore", pu.recuperaTipoSchedaGara(iddoc), "CDC", esito, "", "", DateTime.Now, DateTime.Now, DateTime.Now, -20, 0, "OUT");
                        }
                        catch
                        {
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

        /// <summary>
        /// Recupera il centro di costo fornito un iddoc sulla base del codice Fiscale
        /// </summary>
        /// <param name="iddoc"></param>
        /// <param name="idAzi"></param>
        /// <returns>1#Codice or 0#Errore</returns>
        [HttpGet]
        [ActionName("recuperaCDC")]
        public HttpResponseMessage recuperaCDC(int iddoc, string idAzi)
        {
            string esito = "1#OK";
            string strCause = "recuperaCDC - START";

            bool traceError = true;
            PDNDUtils pu = new PDNDUtils();

            try
            {

                strCause = "recuperaDatiPerVoucher";
                Dati_PCP dati = pu.recuperaDatiPerVoucher(iddoc, "AUSA", "/api/ausa/getBy");

                HttpMethod method = pu.recuperaMetodoDaServizio("/api/ausa/getBy");

                string endpointContesto = dati.aud;
                string endpointContestuale = $"{endpointContesto}/api/ausa/getBy";

                string result = string.Empty;

                //Tramite l'idazi Recupero il codice fiscale dell'azienda e poi il codice AUSA
                string codiceFiscale = pu.recuperaCodiceFiscale(idAzi);
                
                //Le tengo separate per eventuali modifiche o debug
                string codiceAusa = pu.recuperaCodiceAusa(codiceFiscale);

                strCause = "Chiamata alla Get Barer Token";
                var objVoucher = pu.GetBarerToken(dati, iddoc);

                if (method == HttpMethod.Get)
                {
                    Dictionary<string, string> data = new Dictionary<string, string>();
                    data.Add("codiceAusa", codiceAusa);

                    strCause = "sendRequest";
                    result = pu.sendRequest(objVoucher.client, endpointContestuale, "", objVoucher.voucher, objVoucher.jwtWithData, method, parametri: data, idDoc: iddoc);
                }
                else
                {
                    throw new NotImplementedException();
                }


                string endpointWithQS = endpointContestuale + "?codiceAusa=" + codiceAusa;

                strCause = "Deserialize della risposta";
                RispostaAusaCDC risposta = JsonSerializer.Deserialize<RispostaAusaCDC>(result);
                string errore = "";
                List<CentroDiCostoLight> listcdc = new List<CentroDiCostoLight>();

                try
                {
                    strCause = "Iteriamo sui centri di costo";
                    foreach (var item in risposta.items[0].scheda.stazioneAppaltante.centriDiCosto)
                    {
                        CentroDiCostoLight cdcl = new CentroDiCostoLight();
                        cdcl.idCentroDiCosto = item.idCentroDiCosto;
                        cdcl.denominazioneCentroDiCosto = item.denominazioneCentroDiCosto;
                        if (item.stato.stato != null && item.stato.stato.ToUpper() == "ATTIVO")
                        {
                            listcdc.Add(cdcl);
                        }
                    }

                }
                catch (Exception ex)
                {
                    errore = $"Impossibile recuperare il Codice Centro di Costo : {ex.Message}";
                }

                strCause = "Test della risposta";
                if (risposta.code == 200 && errore == "" && listcdc.Count > 0)
                {
                    //pu.inserisciLogIntegrazione(iddoc, "recuperaCDC", "Elaborato", pu.recuperaTipoSchedaGara(iddoc), "CDC", "", endpointWithQS, result, DateTime.Now, DateTime.Now, DateTime.Now, -20, dati.idAzi, "OUT");
                    esito = JsonSerializer.Serialize<List<CentroDiCostoLight>>(listcdc);
                }
                else
                {
                    pu.inserisciLogIntegrazione(iddoc, "recuperaCDC", "Errore", pu.recuperaTipoSchedaGara(iddoc), "CDC", risposta.title, endpointWithQS, result, DateTime.Now, DateTime.Now, DateTime.Now, -20, dati.idAzi, "OUT");
                    traceError = false;
                    throw new ApplicationException("l'operazione recuperaCDC non ha restituito un codice 200 - " + risposta.title);
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
                //Se ho avuto eccezione per un motivo qualsiasi ( cioè passo da uno dei catch ) passo lo stato della scheda ad errore ed inserirco un log di Errore in cronologia
                if (esito.StartsWith("0#"))
                {
                    strCause = "Inserimento trace di errore";
                    pu.InsertTrace("PCP", $"Errore nel metodo di recuperaCDC : {esito}", iddoc);

                    if (traceError)
                    {
                        try
                        {
                            pu.inserisciLogIntegrazione(iddoc, "recuperaCDC", "Errore", pu.recuperaTipoSchedaGara(iddoc), "CDC", esito, "", "", DateTime.Now, DateTime.Now, DateTime.Now, -20, 0, "OUT");
                        }
                        catch
                        {
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

        [HttpGet]
        [ActionName("pubblicaAvviso")]
        public HttpResponseMessage pubblicaAvviso(int idDoc)
        {
            string esito = "1#OK";
            string strCause = "pubblicaAvviso - START";

            PDNDUtils pu = new PDNDUtils();
            bool traceError = true;

            try
            {

                strCause = "pubblicaAvviso - start recuperaDatiPerVoucher";

                Dati_PCP dati = pu.recuperaDatiPerVoucher(idDoc, "Pubblica avviso", "/pubblica-avviso");

                strCause = "pubblicaAvviso - Recupero id avviso ed id appalto";
                string idAvviso = pu.recuperaIdAvviso(idDoc);
                string idAppalto = pu.recuperaIdAppalto(idDoc);

                string json = JsonSerializer.Serialize(new { idAvviso = idAvviso, idAppalto = idAppalto });

                strCause = "pubblicaAvviso - start recuperaMetodoDaServizio";
                HttpMethod method = pu.recuperaMetodoDaServizio("/pubblica-avviso");

                string endpointContesto = dati.aud;
                string endpointContestuale = $"{endpointContesto}/pubblica-avviso";

                strCause = "Chiamata alla Get Barer Token";
                var objVoucher = pu.GetBarerToken(dati, idDoc);

                strCause = "pubblicaAvviso - start POST /pubblica-avviso verso ANAC";
                string result = string.Empty;
                result = pu.postRequest(objVoucher.client, endpointContestuale, "", objVoucher.voucher, objVoucher.jwtWithData, method, body: json, idDoc: idDoc);

                RispostaBase risposta = JsonSerializer.Deserialize<RispostaBase>(result);
                string rispostaJson = JsonSerializer.Serialize(risposta);
                if (risposta.status == 200)
                {
                    pu.inserisciLogIntegrazione(idDoc, "pubblica-avviso", "Elaborato", pu.recuperaTipoSchedaGara(idDoc), "idAppalto", "", json, rispostaJson, DateTime.Now, DateTime.Now, DateTime.Now, -20, dati.idAzi, "OUT");
                    pu.avviaEsitoOperazione(-22, idDoc, "pubblica-avviso");
                }
                else
                {
                    pu.inserisciLogIntegrazione(idDoc, "pubblica-avviso", "Errore", pu.recuperaTipoSchedaGara(idDoc), "idAppalto", risposta.detail, json, rispostaJson, DateTime.Now, DateTime.Now, DateTime.Now, -20, dati.idAzi, "OUT");
                    traceError = false;
                    throw new ApplicationException($"L'operazione pubblica-avviso non è stata eseguita correttamente : {risposta.detail}");
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
                //Se ho avuto eccezione per un motivo qualsiasi ( cioè passo da uno dei catch ) passo lo stato della scheda ad errore ed inserirco un log di Errore in cronologia
                if (esito.StartsWith("0#"))
                {
                    strCause = "Inserimento trace di errore";
                    pu.InsertTrace("PCP", $"Errore nel metodo di pubblicaAvviso : {esito}", idDoc);

                    if (traceError)
                    {
                        try
                        {
                            pu.inserisciLogIntegrazione(idDoc, "pubblica-avviso", "Errore", pu.recuperaTipoSchedaGara(idDoc), "idAppalto", esito, "", "", DateTime.Now, DateTime.Now, DateTime.Now, -20, 0, "OUT");
                        }
                        catch
                        {
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

        /// <summary>
        /// API Rest utile all'invocazione del WS anac di consulta-avviso
        /// </summary>
        /// <param name="idDoc">ID della procedura di gara</param>
        /// <param name="idRow">(opz) ID della tabella Services_Integration_Request</param>
        /// <param name="idpfu">(opz) ID dell'utente in sessione</param>
        /// <returns>Output testuale contenente 1#OK per esito positivo e 0#MsgDiErrore per esito negativo</returns>
        [HttpGet]
        [ActionName("consultaAvviso")]
        public HttpResponseMessage consultaAvviso(int idDoc, int idRow = 0,int idpfu = 0)
        {
            string esito = "1#OK";
            string servizio = "/consulta-avviso";
            string strCause = $"{servizio} - START";

            PDNDUtils pu = new PDNDUtils();
            bool traceError = true;

            string payloadOut = string.Empty;
            string payloadIN = string.Empty;

            try
            {

                strCause = $"{servizio} - start recuperaDatiPerVoucher";

                Dati_PCP dati = pu.recuperaDatiPerVoucher(idDoc, "Pubblica avviso", servizio);

                strCause = $"{servizio} - Recupero id avviso";
                string idAvviso = pu.recuperaIdAvviso(idDoc);

                Dictionary<string, string> data = new Dictionary<string, string>
                {
                    { "idAvviso", idAvviso }
                };

                string endpointContesto = dati.aud;
                string endpointContestuale = $"{endpointContesto}{servizio}";

                payloadIN = $"{endpointContestuale}?idAvviso={idAvviso}";

                strCause = "Chiamata alla Get Barer Token";
                var objVoucher = pu.GetBarerToken(dati, idDoc);

                strCause = $"{servizio} - start GET {servizio} verso ANAC";
                payloadOut = pu.sendRequest(objVoucher.client, endpointContestuale, "", objVoucher.voucher, objVoucher.jwtWithData, HttpMethod.Get, parametri: data, idDoc: idDoc);

                ConsultaAvviso risposta = JsonSerializer.Deserialize<ConsultaAvviso>(payloadOut);

                //Se otteniamo una risposta di KO/Errore
                if (risposta.status != 200)
                    throw new ApplicationException($"L'operazione {servizio} non è stata eseguita correttamente : {risposta.detail}");

                //RISPOSTA DI OK/POSITIVA

                if (idRow > 0)
                {
                    //Aggiorniamo la sentinella per esito positivo insieme ad input ed output ricevuto
                    pu.UpdateServiceIntegration(idRow, "Elaborato", 1, "", payloadIN, payloadOut);
                }
                else
                {
                    //Se questa API è stata chiamata tramite una richiesta sincrona direttamente dall'interfaccia ( quindi non ho la sentinella )
                    //  allora dobbiamo inserire di iniziativa una traccia nella cronologia, viceversa aggiorniamo quella già presente
                    pu.inserisciLogIntegrazione(idDoc, "consulta-avviso", "Elaborato", null, "", "", payloadIN, payloadOut, DateTime.Now, DateTime.Now, DateTime.Now, idpfu, dati.idAzi, "OUT");
                }

                //datiPubblicazioneEU non deve essere null ed a seguire dataPubblicazione deve essere valorizzato
                if (risposta.avviso.datiPubblicazioneEU?.dataPubblicazione != null)
                {
                    //Chiamata alla stored di inserimento dati di pubblicazione EU.
                    // Aggiornamento/nuova riga con codice/tipo pubbliczione 'PVL'
                    pu.salvaDatiPubblicazioneEU(idDoc, risposta.avviso.datiPubblicazioneEU.dataPubblicazione, risposta.avviso.datiPubblicazioneEU.publicationId, risposta.avviso.datiPubblicazioneEU.publicationUrl);
                }

                //datiPubblicazioneIT non deve essere null ed a seguire dataPubblicazione deve essere valorizzato
                if (risposta.avviso.datiPubblicazioneIT?.dataPubblicazione != null)
                {
                    //  Aggiornamento/nuova riga con codice/tipo pubbliczione 'PVL'
                    pu.salvaDatiPubblicazioneIT(idDoc, risposta.avviso.datiPubblicazioneIT.dataPubblicazione, risposta.avviso.datiPubblicazioneIT.idAvvisoPVL);
                }
                else //La data di pubblicazione per la PVL può essere ottenuta fino a 48 ore dopo la pubblicazione dell'avviso
                {
                    //I dati di pubblicazione IT dovrebbero esserci sempre. Quindi se non li riceviamo vuol dire che abbiamo ottenuto i dati di pubblicazione EU
                    //  ma non erano ancora pronti quelli di pubblicazione IT
                    var utils = new GeneralUtils();
                    long delay = Convert.ToInt64(utils.getDbParam("PCP", "consulta-avviso", "DelayPostPub", "24"));

                    //Scheduliamo un nuovo recupero automatico
                    pu.ScheduleProcess(idDoc, DateTime.Now.AddHours(delay), "PCP", "SENTINELLA_CONSULTA_AVVISO");
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
                esito = "0#" + strCause + " -- " + e;
            }

            try
            {
                //Se ho avuto eccezione per un motivo qualsiasi ( cioè passo da uno dei catch ) passo lo stato della scheda ad errore ed inserirco un log di Errore in cronologia
                if (esito.StartsWith("0#"))
                {
                    strCause = "Inserimento trace di errore";
                    pu.InsertTrace("PCP", $"Errore nel metodo di {servizio} : {esito}", idDoc);

                    try
                    {
                        if (idRow > 0)
                        {
                            pu.UpdateServiceIntegration(idRow, "Errore", 1, "", payloadIN, payloadOut);
                        }
                        else
                        {
                            pu.inserisciLogIntegrazione(idDoc, "consulta-avviso", "Errore", null, "", "", payloadIN, payloadOut, DateTime.Now, DateTime.Now, DateTime.Now, idpfu, 0, "OUT");
                        }
                    }
                    catch
                    {
                    }
                }
            }
            catch (Exception e)
            {
                esito += strCause + " -- " + e;
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

        /// <summary>
        /// 
        /// </summary>
        /// <param name="idRow">ID tabellare della tabella di sentinelle integrazione</param>
        /// <param name="idGara">ID della gara</param>
        /// <param name="idDoc">ID del documento di rettifica dati ( rettifica/proroga/etc ) </param>
        /// <returns></returns>
        [HttpGet]
        [ActionName("rettificaAvviso")]
        public HttpResponseMessage rettificaAvviso(int idRow, int idGara, int idDoc = 0)
        {
            string esito = "1#OK";
            string strCause = "rettificaAvviso - START";

            PDNDUtils pu = new PDNDUtils();

            try
            {
                strCause = "rettificaAvviso - start recuperaDatiPerVoucher";
                Dati_PCP dati = pu.recuperaDatiPerVoucher(idGara, "Pubblica avviso", "/rettifica-avviso");

                strCause = "rettificaAvviso - start recuperaMetodoDaServizio";
                HttpMethod method = pu.recuperaMetodoDaServizio("/rettifica-avviso");

                string endpointContesto = dati.aud;
                string endpointContestuale = $"{endpointContesto}/rettifica-avviso";
                string result = string.Empty;

                strCause = "rettificaAvviso - recupera dati appalto";
                string idAvviso = pu.recuperaIdAvviso(idGara);
                string idAppalto = pu.recuperaIdAppalto(idGara);

                strCause = "rettificaAvviso - recuperaTipoSchedaGara";
                TipoScheda tipoScheda = pu.recuperaTipoSchedaGara(idGara);

                string eformXml64 = "";
                string espdXml64 = "";

                strCause = "rettificaAvviso - RecuperaEFormXml64EspdXml64";
                pu.RecuperaEFormXml64EspdXml64(idGara, ref eformXml64, ref espdXml64, "CN16_CHANGE_NOTICE");

                string json = "";

                object s = pu.compilaScheda(idGara, eformXml64, espdXml64, dati, tipoScheda);

                json = AnacFormUtils.getJsonWithOptAttrib(new { idAvviso = idAvviso, idAppalto = idAppalto, scheda = s });

                strCause = "Chiamata alla Get Barer Token";
                var objVoucher = pu.GetBarerToken(dati, idGara);

                strCause = "rettificaAvviso - start POST /rettifica-avviso verso ANAC";
                result = pu.postRequest(objVoucher.client, endpointContestuale, "", objVoucher.voucher, objVoucher.jwtWithData, method, body: json, idDoc: idGara);

                RispostaBase risposta = JsonSerializer.Deserialize<RispostaBase>(result);

                if (risposta.status == 200)
                {
                    pu.inserisciLogIntegrazione(idGara, "rettifica-avviso", "Elaborato", pu.recuperaTipoSchedaGara(idGara), "idAppalto", "", json, result, DateTime.Now, DateTime.Now, DateTime.Now, -20, 0, "OUT");
                    pu.avviaEsitoOperazione(-22, idGara, "rettifica-avviso");
                    pu.UpdateServiceIntegration(idRow, "Elaborato");
                }
                else
                {
                    pu.inserisciLogIntegrazione(idGara, "rettifica-avviso", "Errore", pu.recuperaTipoSchedaGara(idGara), "idAppalto", risposta.detail, json, result, DateTime.Now, DateTime.Now, DateTime.Now, -20, dati.idAzi, "OUT");
                    throw new ApplicationException("l'operazione rettifica-avviso non è stata eseguita correttamente");
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
                esito = "0#" + strCause + " -- " + e;
            }

            //Se ho avuto un errore
            if ( esito.StartsWith("0#"))
                pu.UpdateServiceIntegration(idRow, "Errore", msgError: esito);

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
        [ActionName("cancellaAppalto")]
        public HttpResponseMessage cancellaAppalto(int idDoc, string motivo = "cancellazione")
        {
            string esito = "1#OK";
            string strCause = "cancellaAppalto - START";

            TipoScheda? tipoScheda = null;
            bool traceError = true;
            PDNDUtils pu = new PDNDUtils();

            string TipoDocGara = "";

            try
            {
                
                TipoDocGara = pu.recuperaTipoDocGara(idDoc);

				tipoScheda = pu.recuperaTipoSchedaGara(idDoc);

                strCause = "cancellaAppalto - start recuperaDatiPerVoucher";

                Dati_PCP dati = pu.recuperaDatiPerVoucher(idDoc, "Comunica appalto", "/cancella-appalto");

                strCause = "cancellaAppalto - start recuperaMetodoDaServizio";
                HttpMethod method = pu.recuperaMetodoDaServizio("/cancella-appalto");

                string endpointContesto = dati.aud;
                string endpointContestuale = $"{endpointContesto}/cancella-appalto";

                string idAppalto = pu.recuperaIdAppalto(idDoc);

                string json = JsonSerializer.Serialize(new
                {
                    idAppalto = idAppalto,
                    motivo = motivo
                });

                strCause = "Chiamata alla Get Barer Token";
                var objVoucher = pu.GetBarerToken(dati, idDoc);

                strCause = "cancellaAppalto - start POST /cancella-appalto verso ANAC";
                string result = string.Empty;
                result = pu.postRequest(objVoucher.client, endpointContestuale, "", objVoucher.voucher, objVoucher.jwtWithData, method, body: json, idDoc: idDoc);

                RispostaCreaAppalto risposta = JsonSerializer.Deserialize<RispostaCreaAppalto>(result);
                //string rispostaJson = JsonSerializer.Serialize(risposta);
                if (risposta.status == 200)
                {
                    pu.inserisciLogIntegrazione(idDoc, "cancella-appalto", "Elaborato", pu.recuperaTipoSchedaGara(idDoc), "idAppalto", "", json, result, DateTime.Now, DateTime.Now, DateTime.Now, -20, dati.idAzi, "OUT");

                    // Il campo “Id appalto ANAC“ verrà sbiancato e la procedura tornerà in edit mode per procedere nuovamente con il click su “Conferma appalto”.
                    pu.AggiornaIdAppalto(idDoc, "");

                    //tolgo i cig dalla gara
                    pu.SvuotaCigGara(idDoc, TipoDocGara);

                    pu.nuovoIdAppaltoCN16(idDoc);

                    strCause = "Passo stato della scheda appalto a Confermato";
                    pu.aggiornaRecordSchedaAppalto(idDoc, -20, pu.traduciTipoScheda(tipoScheda), "AppaltoCancellato");
                }
                else
                {

                    string msgError = $"{risposta.detail} : ";

                    string listErrors = "";

                    //Recuperiamo tutti gli errori, prima era cablato il recupero del solo elemento 0
                    for (int i = 0; i < risposta.errori.Count; i++)
                    {
                        listErrors += $"{risposta.errori[i].codice};";
                    }

                    msgError += listErrors;

                    pu.inserisciLogIntegrazione(idDoc, "cancella-appalto", "Errore", pu.recuperaTipoSchedaGara(idDoc), "idAppalto", msgError, json, result, DateTime.Now, DateTime.Now, DateTime.Now, -20, dati.idAzi, "OUT");
                    traceError = false;
                    throw new ApplicationException($"L'operazione cancella-appalto non è stata eseguita correttamente : {msgError}");
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
                //Se ho avuto eccezione per un motivo qualsiasi ( cioè passo da uno dei catch ) passo lo stato della scheda ad errore ed inserirco un log di Errore in cronologia
                if (esito.StartsWith("0#"))
                {
                    strCause = "Inserimento trace di errore";
                    pu.InsertTrace("PCP", $"Errore nel metodo di cancellaAppalto : {esito}", idDoc);

                    if (traceError)
                    {
                        try
                        {
                            pu.inserisciLogIntegrazione(idDoc, "cancella-appalto", "Errore", pu.recuperaTipoSchedaGara(idDoc), "idAppalto", esito, "", "", DateTime.Now, DateTime.Now, DateTime.Now, -20, 0, "OUT");
                        }
                        catch
                        {
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


        [HttpGet]
        [ActionName("payloadP1_16")]

        public HttpResponseMessage payloadP1_16(int iddoc = -20)
        {
            /*CONTROLLER DI TEST PER RECUPERARE SOLO IL PAYLOAD DELLA SCHEDA S1*/
            if (iddoc <= 0)
                throw new Exception("Parametro iddoc obbligatorio. deve contenere l'id della gara");



            string json = getPayloadP1_16(iddoc);

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
        [ActionName("payloadP2_16")]

        public HttpResponseMessage payloadP2_16(int iddoc = -20)
        {
            /*CONTROLLER DI TEST PER RECUPERARE SOLO IL PAYLOAD DELLA SCHEDA S1*/
            if (iddoc <= 0)
                throw new Exception("Parametro iddoc obbligatorio. deve contenere l'id della gara");



            string json = getPayloadP2_16(iddoc);

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
        [ActionName("payloadP7_1_2")]

        public HttpResponseMessage payloadP7_1_2(int iddoc = -20)
        {
            /*CONTROLLER DI TEST PER RECUPERARE SOLO IL PAYLOAD DELLA SCHEDA S1*/
            if (iddoc <= 0)
                throw new Exception("Parametro iddoc obbligatorio. deve contenere l'id della gara");



            string json = getPayloadP7_1_2(iddoc);

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
        [ActionName("payloadP7_1_3")]

        public HttpResponseMessage payloadP7_1_3(int iddoc = -20)
        {
            /*CONTROLLER DI TEST PER RECUPERARE SOLO IL PAYLOAD DELLA SCHEDA S1*/
            if (iddoc <= 0)
                throw new Exception("Parametro iddoc obbligatorio. deve contenere l'id della gara");



            string json = getPayloadP7_1_3(iddoc);

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
        [ActionName("payloadP7_2")]

        public HttpResponseMessage payloadP7_2(int iddoc = -20)
        {
            /*CONTROLLER DI TEST PER RECUPERARE SOLO IL PAYLOAD DELLA SCHEDA S1*/
            if (iddoc <= 0)
                throw new Exception("Parametro iddoc obbligatorio. deve contenere l'id della gara");



            string json = getPayloadP7_2(iddoc);

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
        [ActionName("payloadAD_5")]
        public HttpResponseMessage payloadAD_5(int iddoc = -20)
        {
            /*CONTROLLER DI TEST PER RECUPERARE SOLO IL PAYLOAD DELLA SCHEDA S1*/
            if (iddoc <= 0)
                throw new Exception("Parametro iddoc obbligatorio. deve contenere l'id della gara");



            string json = getPayloadAD_5(iddoc);

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
		[ActionName("payloadAD4")]
		public HttpResponseMessage payloadAD4(int iddoc = -20)
		{
			/*CONTROLLER DI TEST PER RECUPERARE SOLO IL PAYLOAD DELLA SCHEDA S1*/
			if (iddoc <= 0)
				throw new Exception("Parametro iddoc obbligatorio. deve contenere l'id della gara");



			string json = getPayloadAD4(iddoc);

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
        [ActionName("payloadAD_3")]
        public HttpResponseMessage payloadAD_3(int iddoc = -20)
        {
            /*CONTROLLER DI TEST PER RECUPERARE SOLO IL PAYLOAD DELLA SCHEDA S1*/
            if (iddoc <= 0)
                throw new Exception("Parametro iddoc obbligatorio. deve contenere l'id della gara");



            string json = getPayloadAD_3(iddoc);

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
        [ActionName("payloadAD2_25")]
        public HttpResponseMessage payloadAD2_25(int iddoc = -20)
        {
            /*CONTROLLER DI TEST PER RECUPERARE SOLO IL PAYLOAD DELLA SCHEDA S1*/
            if (iddoc <= 0)
                throw new Exception("Parametro iddoc obbligatorio. deve contenere l'id della gara");



            string json = getPayloadAD2_25(iddoc);

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
        [ActionName("payloadA3_6")]
        public HttpResponseMessage payloadA3_6(int iddoc = -20)
        {
            /*CONTROLLER DI TEST PER RECUPERARE SOLO IL PAYLOAD DELLA SCHEDA S1*/
            if (iddoc <= 0)
                throw new Exception("Parametro iddoc obbligatorio. deve contenere l'id della gara");



            string json = getPayloadA3_6(iddoc);

            return new HttpResponseMessage()
            {
                Content = new StringContent(
                    json,
                    Encoding.UTF8,
                    "application/json"
                )
            };

        }


        public string getPayloadP1_16(int idGara)
        {
            PDNDUtils pu = new PDNDUtils();
            Dati_PCP dati = pu.recuperaDatiPerVoucher(idGara);
            object s = pu.compilaScheda(idGara, "", "", dati, TipoScheda.P1_16);

            BaseModel basemodelP1_16 = new BaseModel();
            basemodelP1_16.scheda = (Scheda)s;

            //return JsonSerializer.Serialize(basemodelP1_16);

            return AnacFormUtils.getJsonWithOptAttrib(basemodelP1_16);

        }

        public string getPayloadP2_16(int idGara)
        {
            PDNDUtils pu = new PDNDUtils();
            Dati_PCP dati = pu.recuperaDatiPerVoucher(idGara);
            object s = pu.compilaScheda(idGara, "", "", dati, TipoScheda.P2_16);

            BaseModelP2_16 basemodelP2_16 = new BaseModelP2_16();
            basemodelP2_16.scheda = (SchedaP2_16)s;

            return AnacFormUtils.getJsonWithOptAttrib(basemodelP2_16);

        }

        public string getPayloadP7_1_2(int idGara)
        {
            PDNDUtils pu = new PDNDUtils();
            Dati_PCP dati = pu.recuperaDatiPerVoucher(idGara);
            object s = pu.compilaScheda(idGara, "", "", dati, TipoScheda.P7_1_2);

            BaseModelP7_1_2 baseModelP7_1_2 = new BaseModelP7_1_2();
            //baseModelP7_2.idAppalto = idAppalto;
            baseModelP7_1_2.scheda = (SchedaP7_1_2)s;



            //return JsonSerializer.Serialize(baseModelP7_1_2);
            return AnacFormUtils.getJsonWithOptAttrib(baseModelP7_1_2);

        }

        public string getPayloadP7_1_3(int idGara)
        {
            PDNDUtils pu = new PDNDUtils();
            Dati_PCP dati = pu.recuperaDatiPerVoucher(idGara);
            object s = pu.compilaScheda(idGara, "", "", dati, TipoScheda.P7_1_3);

            BaseModelP7_1_3 baseModelP7_1_3 = new BaseModelP7_1_3();
            //baseModelP7_2.idAppalto = idAppalto;
            baseModelP7_1_3.scheda = (SchedaP7_1_3)s;


            return AnacFormUtils.getJsonWithOptAttrib(baseModelP7_1_3);

        }

        public string getPayloadP7_2(int idGara)
        {
            PDNDUtils pu = new PDNDUtils();
            Dati_PCP dati = pu.recuperaDatiPerVoucher(idGara);
            object s = pu.compilaScheda(idGara, "", "", dati, TipoScheda.P7_2);

            var baseModelP7_2 = new BaseModelModificaP7_2();
            //baseModelP7_2.idAppalto = idAppalto;
            baseModelP7_2.scheda = (SchedaP7_2)s;
            //return JsonSerializer.Serialize(baseModelP7_2);
            return AnacFormUtils.getJsonWithOptAttrib(baseModelP7_2);

        }


        public string getPayloadAD_5(int idGara)
        {
            PDNDUtils pu = new PDNDUtils();
            Dati_PCP dati = pu.recuperaDatiPerVoucher(idGara);
            object s = pu.compilaScheda(idGara, "", "", dati, TipoScheda.AD_5);

            BaseModelAD3 basemodelAD_3 = new BaseModelAD3();
            basemodelAD_3.scheda = (SchedaAD3)s;
            //json = JsonSerializer.Serialize(basemodelAD_3);
            return AnacFormUtils.getJsonWithOptAttrib(basemodelAD_3);



        }

		public string getPayloadAD4(int idGara)
		{
			PDNDUtils pu = new PDNDUtils();
			Dati_PCP dati = pu.recuperaDatiPerVoucher(idGara);
			object s = pu.compilaScheda(idGara, "", "", dati, TipoScheda.AD_4);

			BaseModelAD4 basemodelAD_4 = new BaseModelAD4();
			basemodelAD_4.scheda = (SchedaAD4)s;
			//json = JsonSerializer.Serialize(basemodelAD_3);
			return AnacFormUtils.getJsonWithOptAttrib(basemodelAD_4);



		}


		public string getPayloadAD_3(int idGara)
        {
            PDNDUtils pu = new PDNDUtils();
            Dati_PCP dati = pu.recuperaDatiPerVoucher(idGara);
            object s = pu.compilaScheda(idGara, "", "", dati, TipoScheda.AD_3);

            BaseModelAD3 basemodelAD_3 = new BaseModelAD3();
            basemodelAD_3.scheda = (SchedaAD3)s;
            //json = JsonSerializer.Serialize(basemodelAD_3);
            return AnacFormUtils.getJsonWithOptAttrib(basemodelAD_3);



        }


        public string getPayloadAD2_25(int idGara)
        {
            PDNDUtils pu = new PDNDUtils();
            Dati_PCP dati = pu.recuperaDatiPerVoucher(idGara);
            object s = pu.compilaScheda(idGara, "", "", dati, TipoScheda.AD2_25);

            BaseModelAD2_25 basemodelAD2_25 = new BaseModelAD2_25();
            basemodelAD2_25.scheda = (SchedaAd2_25)s;
            //json = JsonSerializer.Serialize(basemodelAD_3);
            return AnacFormUtils.getJsonWithOptAttrib(basemodelAD2_25);



        }

        public string getPayloadA3_6(int idGara)
        {
            PDNDUtils pu = new PDNDUtils();
            Dati_PCP dati = pu.recuperaDatiPerVoucher(idGara);
            object s = pu.compilaScheda(idGara, "", "", dati, TipoScheda.A3_6);

            BaseModelA3_6 basemodelA3_6 = new BaseModelA3_6();
            basemodelA3_6.scheda = (SchedaA3_6)s;
            return AnacFormUtils.getJsonWithOptAttrib(basemodelA3_6);
        }



        [HttpGet]
        [ActionName("modificaAppalto")]
        public HttpResponseMessage modificaAppalto(int idDoc)
        {
            string esito = "1#OK";
            string strCause = "modificaAppalto - START";
            bool traceError = true;
            PDNDUtils pu = new PDNDUtils();

            try
            {

                TipoScheda tipoScheda = pu.recuperaTipoSchedaGara(idDoc);

                string eformXml64 = "";
                string espdXml64 = "";

                pu.RecuperaEFormXml64EspdXml64(idDoc, ref eformXml64, ref espdXml64);

                strCause = "modificaAppalto - start recuperaDatiPerVoucher";

                Dati_PCP dati = pu.recuperaDatiPerVoucher(idDoc, "Comunica appalto", "/modifica-appalto");

                strCause = "modificaAppalto - start recuperaMetodoDaServizio";
                HttpMethod method = pu.recuperaMetodoDaServizio("/modifica-appalto");

                string endpointContesto = dati.aud;
                string endpointContestuale = $"{endpointContesto}/modifica-appalto";

                strCause = "modificaAppalto - creazione request body";
                object s = pu.compilaScheda(idDoc, eformXml64, espdXml64, dati, tipoScheda);

                string idAppalto = pu.recuperaIdAppalto(idDoc);

                string json = "";
                switch (tipoScheda)
                {
                    case TipoScheda.P1_16:
                        BaseModelModifica basemodelP1_16 = new BaseModelModifica();
                        basemodelP1_16.idAppalto = idAppalto;
                        basemodelP1_16.scheda = (Scheda)s;
                        json = JsonSerializer.Serialize(basemodelP1_16);
                        break;
                    case TipoScheda.AD_3:
                        BaseModelModificaAD3 basemodelAD_3 = new BaseModelModificaAD3();
                        basemodelAD_3.idAppalto = idAppalto;
                        basemodelAD_3.scheda = (SchedaAD3)s;
                        json = JsonSerializer.Serialize(basemodelAD_3);
                        break;
                    case TipoScheda.AD2_25:
                        var baseModelAD2_25 = new BaseModelGenericModifica<SchedaGeneric<BodyAD2_25>>();
                        baseModelAD2_25.idAppalto = idAppalto;
                        baseModelAD2_25.scheda = (SchedaGeneric<BodyAD2_25>)s;
                        json = JsonSerializer.Serialize(baseModelAD2_25);
                        break;
                    case TipoScheda.P7_2:
                        var baseModelP7_2 = new BaseModelModificaP7_2();
                        baseModelP7_2.idAppalto = idAppalto;
                        baseModelP7_2.scheda = (SchedaP7_2)s;
                        json = JsonSerializer.Serialize(baseModelP7_2);
                        break;
                    case TipoScheda.P7_1_3:
                        var baseModelP7_1_3 = new BaseModelModificaP7_1_3();
                        baseModelP7_1_3.idAppalto = idAppalto;
                        baseModelP7_1_3.scheda = (SchedaP7_1_3)s;
                        json = JsonSerializer.Serialize(baseModelP7_1_3);
                        break;
                    default:
                        break;
                }

                strCause = "Chiamata alla Get Barer Token";
                var objVoucher = pu.GetBarerToken(dati, idDoc);

                strCause = "modificaAppalto - start post /modifica-appalto verso ANAC";
                string result = pu.postRequest(objVoucher.client, endpointContestuale, "", objVoucher.voucher, objVoucher.jwtWithData, method, body: json, idDoc: idDoc);

                RispostaCreaAppalto risposta = JsonSerializer.Deserialize<RispostaCreaAppalto>(result);
                string rispostaJson = JsonSerializer.Serialize(risposta);
                if (risposta.status == 200)
                {
                    pu.inserisciLogIntegrazione(idDoc, "modifica-appalto", "Elaborato", pu.recuperaTipoSchedaGara(idDoc), "idAppalto+Payload", "", json, rispostaJson, DateTime.Now, DateTime.Now, DateTime.Now, -20, dati.idAzi, "OUT");

                    ConfermaAppaltoController confermaAppaltoController = new ConfermaAppaltoController();
                    return confermaAppaltoController.confermaAppalto(idDoc, -22, idAppalto);
                }
                else
                {
                    pu.inserisciLogIntegrazione(idDoc, "modifica-appalto", "Errore", pu.recuperaTipoSchedaGara(idDoc), "idAppalto+Payload", risposta.detail, json, rispostaJson, DateTime.Now, DateTime.Now, DateTime.Now, -20, dati.idAzi, "OUT");
                    traceError = false;
                    throw new ApplicationException("l'operazione modifica-appalto non è stata eseguita correttamente");
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
                //Se ho avuto eccezione per un motivo qualsiasi ( cioè passo da uno dei catch ) passo lo stato della scheda ad errore ed inserirco un log di Errore in cronologia
                if (esito.StartsWith("0#"))
                {

                    strCause = "Inserimento trace di errore";
                    pu.InsertTrace("PCP", $"Errore nel metodo di modificaAppalto : {esito}", idDoc);

                    if (traceError)
                    {
                        try
                        {
                            pu.inserisciLogIntegrazione(idDoc, "modifica-appalto", "Errore", pu.recuperaTipoSchedaGara(idDoc), "idAppalto+Payload", esito, "", "", DateTime.Now, DateTime.Now, DateTime.Now, -20, 0, "OUT");
                        }
                        catch
                        {
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
    }
}
