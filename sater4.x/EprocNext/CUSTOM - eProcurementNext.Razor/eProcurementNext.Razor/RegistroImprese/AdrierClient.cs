//using Microsoft.VisualBasic;
//using Microsoft.VisualBasic.CompilerServices;
using ParixClient.emiliaromagna.servizicner;
using System.Collections;
using System.Data.SqlClient;
using System.Net;
using System.ServiceModel;
using System.Xml;
//using ParixClient.it.lepida.adrier;
using eProcurementNext.CommonModule;
using eProcurementNext.CommonDB;
using StackExchange.Redis;

namespace eProcurementNext.RegistroImprese
{

	public class ClasseAdrierClient : IParixClient
	{

		private string userUlExtraRegionali; // = "Sater.RER";  // TODO prendere da configurazione
		private string pswdUlExtraRegionali; // = "credrucacr"; // TODO prendere da configurazione
		private string bloccoRecuperoRapLeg;

		private bool noSaveDB = false;
		private Dictionary<string, object> datiRegistroImprese = new Dictionary<string, object>();

		CommonDbFunctions cdf = new CommonDbFunctions();
		private DebugTrace dt = new DebugTrace();
		public ClasseAdrierClient()
		{

			// TODO Recuperare queste 3 variabiabili dall'appsettings. Inserirle in un sezione dedicata, "RegistroImprese" o qualcosa del genere. Al suo interno poi
			//      inserire un ulteriore sotto sezione con "Adrier" e poi lì le chiavi necessarie.

			userUlExtraRegionali = ConfigurationServices.GetKey("RegistroImprese:ADRIER:username");
			pswdUlExtraRegionali = ConfigurationServices.GetKey("RegistroImprese:ADRIER:password");
			bloccoRecuperoRapLeg = ConfigurationServices.GetKey("RegistroImprese:ADRIER:bloccoRecuperoRapLeg");

		}

		private string ricercaImpresaPerDenominazione(string ragSoc)
		{

			var client = new ParixClient.it.lepida.adrier.RicercaImpreseClient(); //   RicercaImpreseService();

			string outputXml;

			outputXml = client.RicercaImpresePerDenominazioneAsync(ragSoc, "", userUlExtraRegionali, pswdUlExtraRegionali).Result;

			//Console.Write(outputXml);

			return outputXml;

		}

		private string ricercaImpresa(string codFiscale)
		{
			var client = new ParixClient.it.lepida.adrier.RicercaImpreseClient();

			string outputXml;

			outputXml = client.RicercaImpreseNonCessatePerCodiceFiscaleAsync(codFiscale, "", userUlExtraRegionali, pswdUlExtraRegionali).Result;

			return outputXml;

		}

		private string ricercaImpresaTotale(string codFiscale)
		{

			var client = new ParixClient.it.lepida.adrier.RicercaImpreseClient();
			string outputXml;

			outputXml = client.RicercaImpresePerCodiceFiscaleAsync(codFiscale, "", userUlExtraRegionali, pswdUlExtraRegionali).Result;

			return outputXml;

		}

		private string dettaglioImpresa(string CCIAA, string numeroRea)
		{

			// <DATI_ISCRIZIONE_REA>
			// <NREA>348232</NREA>
			// <CCIAA>SA</CCIAA>
			// <FLAG_SEDE>SI</FLAG_SEDE>
			// <DATA>20041105</DATA>
			// <DT_ULT_AGGIORNAMENTO>20140617</DT_ULT_AGGIORNAMENTO>
			// <C_FONTE>RI</C_FONTE>
			// </DATI_ISCRIZIONE_REA>

			var client = new ParixClient.it.lepida.adrier.RicercaImpreseClient();

			string outputXml;

			outputXml = client.DettaglioCompletoImpresaAsync(CCIAA, numeroRea, "", userUlExtraRegionali, pswdUlExtraRegionali).Result;

			//Console.Write(outputXml);

			return outputXml;

		}

		public string getParixInfo(string cf, string sessionId, string connectionString, string includiCessate)
		{


			string getParixInfoRet = default;

			string xmlDettaglioRidotto = "";
			string xmlDettaglioEsteso = "";
			var m_xmld = new XmlDocument();
			XmlNodeList m_nodelist = null;
			XmlNode nodo = null;
			XmlNode tmpNodo = null;
			string output = ""; // vuoto se non c'è errore. viceversa c'è l'errore


			string esito = ""; // -- esito ritornato da parix
			string tipoErrore = "";          // -- codice di errore parix
			string parixError = "";          // -- msg di errore di parix

			// Dim dati As New Collection()
			var dati = new Dictionary<string, object>();

			string formaSoc = "";
			string nagi = "";

			getParixInfoRet = "";
			output = "";

			try
			{
				dt.Write($"REGISTRO_IMPRESA - CF: {cf} - Inizio recupero dettaglio. Parametro includiCessate: {includiCessate}");

				if (includiCessate == "1")
				{
					xmlDettaglioRidotto = ricercaImpresaTotale(cf);
				}
				else
				{
					xmlDettaglioRidotto = ricercaImpresa(cf);
				}

				
			}


			catch (Exception ex)
			{
				xmlDettaglioRidotto = "";
				output = "Errore invocazione Registro Delle Imprese." + ex.Message;
			}


			if (!string.IsNullOrEmpty(xmlDettaglioRidotto))
			{
				dt.Write($"REGISTRO_IMPRESA - CF: {cf} - xmlDettaglio recuperato ok");

                try
				{
					ParixClient.Utils.traceXmlParix(xmlDettaglioRidotto, "DETTAGLIO_RIDOTTO", sessionId, cf, connectionString);
				}
				catch (Exception ex)
				{

				}


				m_xmld.LoadXml(xmlDettaglioRidotto);

				esito = m_xmld.SelectNodes("/RISPOSTA/HEADER/ESITO")[0].InnerText;

				if (esito.ToUpper() == "OK")
				{
					dt.Write($"REGISTRO_IMPRESA - CF: {cf} - esito /RISPOSTA/HEADER/ESITO OK");

                    int totFlagCessazione = 0;
					int totEstremiImpresa = 0;

					// SE IL NUMERO DEGLI ESTREMI IMPRESA E’ UGUALE AL NUMERO DEGLI ESTREMI IMPRESA CONTENENTE IL FLAG CESSAZIONE, ALLORA L’AZIENDA E’ CESSATA. ALTRIMENTI NO
					totFlagCessazione = m_xmld.SelectNodes("//CESSAZIONE").Count;
					totEstremiImpresa = m_xmld.SelectNodes("//ESTREMI_IMPRESA").Count;


					if (!noSaveDB && includiCessate == "1" && totFlagCessazione == totEstremiImpresa)
					{
                        dt.Write($"REGISTRO_IMPRESA - CF: {cf} - AZIENDA_CESSATA");
                        output = "AZIENDA_CESSATA";
					}

					else
					{

						// -- Se troviamo più ESTREMI_IMPRESA

						// -- caso che capitò con parix : 
						// --     Siamo in un caso raro, del tipo che la provincia originale
						// --     al quale era iscritta l'azienda non esiste più o si è divisa
						// --     vedi MI e MB

						// -- caso capitato con adrier :
						// -- un azienda con 6 estremi impresa ne aveva 2 cessati e gli altri 4 no ma verifcando
						// -- sul registro imprese tramite telemaco erano in realtà correttamente tutti cessati tranne 1.

						var listaNodi = new ArrayList();

						if (m_xmld.SelectSingleNode("/RISPOSTA/DATI/LISTA_IMPRESE/@totale").Value == "1")
						{

							nodo = m_xmld.SelectNodes("/RISPOSTA/DATI/LISTA_IMPRESE/ESTREMI_IMPRESA")[0];

							listaNodi.Add(nodo);
						}

						else
						{

							// nodo = getEstremoImpresaAttivo(m_xmld)
							listaNodi = getEstremoImpresaAttivo(m_xmld);

							// If nodo Is Nothing Then
							if (listaNodi is null)
							{
								output = "Errore. Presenti N estremi impresa di cui nessuno non cessato e con numero rea valorizzato";
								return output;
							}

						}

						bool bNotFound = true;


                        dt.Write($"REGISTRO_IMPRESA - CF: {cf} - Inizio ciclo listaNodi");

                        foreach (XmlNode nodoN in listaNodi)
						{

							// -- l'ultimo nodo sul quale abbiamo iterato sarà quello valido
							nodo = nodoN;

							// -- Se l'esito è ok recupero l'impresa e per prendere i dati REA 
							// -- itero sulla lista delle sedi ritornate da parix 
							// -- ( perchè negli archivi DRIS possono essere presenti imprese plurilocalizzate )
							// -- e   poi vado a prendermi soltanto quella con i dati REA della sede legale dell'azienda
							m_nodelist = nodoN.SelectNodes("DATI_ISCRIZIONE_REA");

							string strNREA = "";
							string strCCIAA = "";
							string strANNOCOSTITUZIONE = "";

							//'-- modifica del 22/05/2023 :
							//'La richiesta � quella di modificare la logica applicata nel caso di �REA multipli in ADRI-ER e Telemaco� per la quale viene considerato
							//'il primo Operatore Economico non cessato, con sede legale �si� e numero REA valorizzato.
							//'LA RICHIESTA � DI CONSIDERARE QUELLO PER CUI LA PROVINCIA CORRISPONDE ALLA PROVINCIA DELLA SEDE LEGALE PRESENTE IN SATER, NON IL PRIMO RESTITUITO.

							//'Dim bTrovataSede As Boolean = False

							string cciaaAnag = string.Empty;
							Dictionary<string, object?> param = new Dictionary<string, object?>();
							param.Add("@cf", cf);
							param.Add("@aziacquirente", 0);
							param.Add("@azideleted", 0);

							System.Text.StringBuilder sb = new System.Text.StringBuilder("select isnull(dbo.Get_ProvinciaISTAT( a.aziProvinciaLeg2 ), '') as provincia ");
							sb.Append("from aziende a with(nolock )");
							sb.Append("inner join DM_Attributi dm with(nolock) on dm.lnk = a.idazi and dm.idApp = 1 and dm.dztNome = 'codicefiscale' ");
							sb.Append("where dm.vatValore_FT = @cf and a.aziAcquirente = @aziacquirente and a.aziDeleted = @azideleted");

							string strSql = sb.ToString();

							CommonDbFunctions cdf = new CommonDbFunctions();
							var result = cdf.ExecuteScalar(strSql, connectionString, parcollection: param);

							if (result != null)
							{
								cciaaAnag += result.ToString();
							}

                            dt.Write($"REGISTRO_IMPRESA - CF: {cf} - Inizio ciclo m_nodelist");

                            foreach (XmlNode nodoX in m_nodelist)
							{

								//'-- se é la sede legale e LA PROVINCIA CORRISPONDE ALLA PROVINCIA DELLA SEDE LEGALE PRESENTE IN SATER

								if (ParixClient.Utils.getXPathValue(nodoX, "FLAG_SEDE") == "SI")
								{
									//'-- se non ho cciaaAnag ( caso registrazione oe ) oppure se ho cciaaAnag e corrisponde con la CCIA sulla quale sto iterando
									//If String.IsNullOrEmpty(cciaaAnag) OrElse(String.IsNullOrEmpty(cciaaAnag) = False AndAlso nodoX.SelectSingleNode("CCIAA").InnerText.ToUpper = cciaaAnag.ToUpper) Then

									if (!string.IsNullOrEmpty(cciaaAnag) && nodoX.SelectSingleNode("CCIAA").InnerText.ToUpper() == cciaaAnag.ToUpper())
									{
										strNREA = nodoX.SelectSingleNode("NREA").InnerText;
										strCCIAA = nodoX.SelectSingleNode("CCIAA").InnerText;
									}

									if (strANNOCOSTITUZIONE.Length >= 4)
									{
										strANNOCOSTITUZIONE = nodoX.SelectSingleNode("DATA").InnerText.Substring(0, 4);  // <DATA>20041105</DATA>
									}


									//If String.IsNullOrEmpty(cciaaAnag) = False AndAlso nodoX.SelectSingleNode("CCIAA").InnerText.ToUpper <> cciaaAnag.ToUpper Then

									if (!string.IsNullOrEmpty(cciaaAnag) && nodoX.SelectSingleNode("CCIAA").InnerText.ToUpper() == cciaaAnag.ToUpper()) {
										break;
									}

								}

							}

							if (string.IsNullOrEmpty(strNREA) || string.IsNullOrEmpty(strCCIAA))
							{
								output = "Errore. Nessun elemento di iscrizione REA risulta come sede legale";
								return output;
							}

							// -- recupero le informazioni estese dell'azienda dopo aver ottenuto cciaa e numeroRea
							xmlDettaglioEsteso = dettaglioImpresa(strCCIAA, strNREA);

							m_xmld.LoadXml(xmlDettaglioEsteso);

							// -- verifichiamo se il dettaglio esteso è di un estremo impresa valido
							if (m_xmld.SelectNodes("/RISPOSTA/HEADER/ESITO")[0].InnerText.ToUpper() == "OK")
							{

								bNotFound = false;

								dati.Add("IscrCCIAA", strNREA);
								dati.Add("SedeCCIAA", strCCIAA);

								if (!string.IsNullOrEmpty(strANNOCOSTITUZIONE))
								{
									dati.Add("ANNOCOSTITUZIONE", strANNOCOSTITUZIONE);
								}

								// -- al primo dettaglio esteso valido possiamo uscire dal for
								break;

							}

						}

						try
						{
							ParixClient.Utils.traceXmlParix(xmlDettaglioEsteso, "DETTAGLIO_ESTESO", sessionId, cf, connectionString);
                            dt.Write($"REGISTRO_IMPRESA - CF: {cf} - Utils.traceXmlParix DETTAGLIO_ESTESO OK");
                        }
						catch (Exception ex)
						{
                            dt.Write($"REGISTRO_IMPRESA - CF: {cf} - Utils.traceXmlParix DETTAGLIO_ESTESO FAIL: {ex.Message}");
                        }

						ParixClient.Utils.addFieldToCollection(nodo, "CODICE_FISCALE", dati, "codicefiscale");

						// -- NON RECUPERIAMO PIU PARTITA IVA E DENOMINAZIONE DAL PRIMO WS MA LI PRENDIAMO DAL DETTAGLIO
						// -- VISTO CHE IN ADRIER SEMBRA CHE PIVA E CF NEL PRIMO LIVELLO, PER UN LORO ERRORE, COINCIDONO
						// addFieldToCollection(nodo, "DENOMINAZIONE", dati, "RAGSOC")
						// addFieldToCollection(nodo, "PARTITA_IVA", dati, "PIVA")

						try
						{
							// -- aggiungere la forma giuridica decodificandola da tabella FORMA_GIURIDICA
							formaSoc = nodo.SelectSingleNode("FORMA_GIURIDICA/C_FORMA_GIURIDICA").InnerText;
							nagi = ParixClient.Utils.getDescFormaSoc(formaSoc, connectionString);

							dati.Add("NAGI", nagi);

                            dt.Write($"REGISTRO_IMPRESA - CF: {cf} - Utils.getDescFormaSoc {formaSoc} OK");
                        }

						catch (Exception ex)
						{
                            dt.Write($"REGISTRO_IMPRESA - CF: {cf} -NODO FORMA_GIURIDICA/C_FORMA_GIURIDICA Utils.getDescFormaSoc FAIL");
                        }

						// m_xmld.LoadXml(xmlDettaglioEsteso)

						esito = m_xmld.SelectNodes("/RISPOSTA/HEADER/ESITO")[0].InnerText;

						if (esito.ToUpper() == "OK")
						{
                            dt.Write($"REGISTRO_IMPRESA - CF: {cf} - ESITO NODO /RISPOSTA/HEADER/ESITO OK");

                            nodo = m_xmld.SelectNodes("/RISPOSTA/DATI/DATI_IMPRESA/ESTREMI_IMPRESA")[0];
							ParixClient.Utils.addFieldToCollection(nodo, "DENOMINAZIONE", dati, "RAGSOC");
							ParixClient.Utils.addFieldToCollection(nodo, "PARTITA_IVA", dati, "PIVA");

							nodo = m_xmld.SelectSingleNode("/RISPOSTA/DATI/DATI_IMPRESA/INFORMAZIONI_SEDE/INDIRIZZO");

							// -- recupero la codifica del comune, se presente, ed in base a questa recupero il resto
							string cod_comune = "";
							string dmv_codComune = "";
							string descComune = "";
							string codeProv = "";
							string descProv = "";
							string[] vet;

                            dt.Write($"REGISTRO_IMPRESA - CF: {cf} - Blocco codice recupero Comune/i");

                            if (nodo.SelectNodes("C_COMUNE").Count > 0)
							{

								cod_comune = nodo.SelectNodes("C_COMUNE")[0].InnerText;

								if (!String.IsNullOrEmpty(cod_comune))
								{

									ParixClient.Utils.getComune(cod_comune, ref dmv_codComune, ref descComune, connectionString);

									dati.Add("aziLocalitaLeg2", dmv_codComune);
									dati.Add("LOCALITALEG", descComune);

									vet = dmv_codComune.Split('-');

									// -- Recupero la provincia a partire dal figlio ( il comune )
									//codeProv = Strings.Replace(dmv_codComune, "-" + vet[Information.UBound(vet)], ""); 
									codeProv = dmv_codComune.Replace("-" + vet[vet.GetUpperBound(0)], "");

									descProv = ParixClient.Utils.getProvincia(codeProv, connectionString);

									dati.Add("PROVINCIALEG", descProv);
									dati.Add("aziProvinciaLeg2", codeProv);
								}
							}


							// -- se non trovo il nodo con il codice istat del comune passo a vedere se c'è quello con la sola descrizione
							// -- (caso sede estera)
							else if (nodo.SelectNodes("COMUNE").Count > 0)
							{

								descComune = nodo.SelectNodes("COMUNE")[0].InnerText;

								dati.Add("LOCALITALEG", descComune);
								dati.Add("PROVINCIALEG", "");
								dati.Add("aziLocalitaLeg2", "");
								dati.Add("aziProvinciaLeg2", "");


							}

							ParixClient.Utils.addFieldToCollection(nodo, "CAP", dati, "CAPLEG");

                            dt.Write($"REGISTRO_IMPRESA - CF: {cf} - Blocco codice recupero indirizzo");

                            if (nodo.SelectNodes("VIA").Count > 0)
							{
								string via = "";
								string toponimo = "";
								string civico = "";

								via = nodo.SelectNodes("VIA")[0].InnerText;

								if (nodo.SelectNodes("TOPONIMO").Count > 0)
								{
									toponimo = nodo.SelectNodes("TOPONIMO")[0].InnerText;
								}

								if (nodo.SelectNodes("N_CIVICO").Count > 0)
								{
									civico = " " + nodo.SelectNodes("N_CIVICO")[0].InnerText;
									dati.Add("aziNumeroCivico", nodo.SelectNodes("N_CIVICO")[0].InnerText);
								}

								via = toponimo + " " + via + civico;

								dati.Add("INDIRIZZOLEG", via);

							}

							ParixClient.Utils.addFieldToCollection(nodo, "TELEFONO", dati, "NUMTEL");
							ParixClient.Utils.addFieldToCollection(nodo, "FAX", dati, "NUMFAX");

							ParixClient.Utils.addFieldToCollection(nodo, "INDIRIZZO_PEC", dati, "EMail");

							// -- Recupero semplificato RapLeg. mod. per att. 413855
							// --     salviamo i dati in campi dedicati. recuperati ad es. per il sitar

							m_nodelist = m_xmld.SelectNodes("/RISPOSTA/DATI/DATI_IMPRESA/PERSONE_SEDE/PERSONA");

                            dt.Write($"REGISTRO_IMPRESA - CF: {cf} - Blocco codice /RISPOSTA/DATI/DATI_IMPRESA/PERSONE_SEDE/PERSONA");

                            foreach (XmlNode currentNodo in m_nodelist)
							{
								nodo = currentNodo;

								// -- iteriamo su tutte le persone fino a trovare la PRIMA indicata come rappresentante
								if (nodo.SelectNodes("RAPPRESENTANTE").Count > 0)
								{

									if (nodo.SelectNodes("RAPPRESENTANTE")[0].InnerText.ToUpper() == "SI")
									{

										ParixClient.Utils.addFieldToCollection(nodo, "PERSONA_FISICA/NOME", dati, "PERSONA_FISICA_NOME");
										ParixClient.Utils.addFieldToCollection(nodo, "PERSONA_FISICA/COGNOME", dati, "PERSONA_FISICA_COGNOME");
										ParixClient.Utils.addFieldToCollection(nodo, "PERSONA_FISICA/CODICE_FISCALE", dati, "PERSONA_FISICA_CODICE_FISCALE");

										break;

									}

								}

							}

							if (bloccoRecuperoRapLeg.ToUpper() != "YES")
							{
                                dt.Write($"REGISTRO_IMPRESA - CF: {cf} - Blocco codice /RISPOSTA/DATI/DATI_IMPRESA/PERSONE_SEDE/PERSONA bloccoRecuperoRapLeg != YES");

                                ParixClient.Utils.addFieldToCollection(nodo, "INDIRIZZO_PEC", dati, "PFUEMAIL");

								m_nodelist = m_xmld.SelectNodes("/RISPOSTA/DATI/DATI_IMPRESA/PERSONE_SEDE/PERSONA");

								string carica = "";
								string descCaricaLegRap = "";
								int ruolo = -1;
								int ruoloRapLeg = 10000;
								XmlNode nodoRapLeg = null;

								XmlNodeList cariche = null;

								foreach (XmlNode currentNodo1 in m_nodelist)
								{
									nodo = currentNodo1;


									// -- Itero sulle N possibili cariche di ogni persona per vedere se tra queste
									// -- c'è una di rapLeg
									cariche = nodo.SelectNodes("CARICHE/CARICA");

									foreach (XmlNode nodo_carica in cariche)
									{

										carica = nodo_carica.SelectSingleNode("C_CARICA").InnerText;

										ruolo = ParixClient.Utils.getRuoloRapLeg(carica, connectionString);

										// -- se era gia stato assegnato un rappresentante legale controllo se quello appena trovato
										// -- ha un importanza maggiore del precedenente (quindi un 'ruolo' con un numero più basso)
										if (ruolo != -1 & ruolo < ruoloRapLeg)
										{

											ruoloRapLeg = ruolo;
											nodoRapLeg = nodo.Clone();
											descCaricaLegRap = nodo_carica.SelectSingleNode("DESCRIZIONE").InnerText;

										}

									}

								}

                                dt.Write($"REGISTRO_IMPRESA - CF: {cf} - Inserimento dati Rappresentante Legale");

                                // -- se è stato trovato un rappresentante legale
                                if (nodoRapLeg is not null)
								{

									ParixClient.Utils.addFieldToCollection(nodoRapLeg, "PERSONA_FISICA/NOME", dati, "NomeRapLeg");
									ParixClient.Utils.addFieldToCollection(nodoRapLeg, "PERSONA_FISICA/COGNOME", dati, "CognomeRapLeg");
									ParixClient.Utils.addFieldToCollection(nodoRapLeg, "PERSONA_FISICA/CODICE_FISCALE", dati, "CFRapLeg");
									// addFieldToCollection(nodoRapLeg, descCaricaLegRap, dati, "RuoloRapLeg")
									dati.Add("RuoloRapLeg", descCaricaLegRap);

								}

							}

							if (noSaveDB != true)
							{
                                dt.Write($"REGISTRO_IMPRESA - CF: {cf} - Blocco codice insertCollectionInDb");
                                ParixClient.Utils.insertCollectionInDb(dati, sessionId, cf, connectionString);
							}
							else
							{
								datiRegistroImprese = dati;
							}
						}

						else
						{
                            dt.Write($"REGISTRO_IMPRESA - CF: {cf} - ESITO NODO /RISPOSTA/HEADER/ESITO FAIL");

                            tipoErrore = m_xmld.SelectNodes("/RISPOSTA/DATI/ERRORE/TIPO")[0].InnerText;
							parixError = m_xmld.SelectNodes("/RISPOSTA/DATI/ERRORE/MSG_ERR")[0].InnerText;

							output = "Errore.[" + tipoErrore + "] - " + parixError;

							ParixClient.Utils.traceXmlParix(output, "ERRORE_DETTAGLIO_ESTESO", sessionId, cf, connectionString);

							// -- SE L'IMPRESA NON E' STATA TROVATA IL CHIAMANTE DEVE INSERIRE LA SENTINELLA DI AZIENDA ANOMALA
							if (tipoErrore.ToUpper().Equals("IMP_OCCORRENZA_0"))
							{
								output = "IMP_OCCORRENZA_0";
							}

						}





					}
				}

				else // KO
				{

					tipoErrore = m_xmld.SelectNodes("/RISPOSTA/DATI/ERRORE/TIPO")[0].InnerText;
					parixError = m_xmld.SelectNodes("/RISPOSTA/DATI/ERRORE/MSG_ERR")[0].InnerText;

					output = "Errore.[" + tipoErrore + "] - " + parixError;

					ParixClient.Utils.traceXmlParix(output, "ERRORE_DETTAGLIO_RIDOTTO", sessionId, cf, connectionString);

					// -- SE L'IMPRESA NON E' STATA TROVATA IL CHIAMANTE DEVE INSERIRE LA SENTINELLA DI AZIENDA ANOMALA
					if (tipoErrore.ToUpper().Equals("IMP_OCCORRENZA_0"))
					{
						output = "IMP_OCCORRENZA_0";
					}

					// <DATI>
					// <ERRORE>
					// <TIPO>CF_PI_errato</TIPO>
					// <MSG_ERR>CODICE FISCALE FORMALMENTE SCORRETTO</MSG_ERR>
					// </ERRORE>

				}
			}

			else
			{

				output = "Errore.Xml di output vuoto. " + output;

			}


			m_xmld = null;
			getParixInfoRet = output;
			return getParixInfoRet;

		}

		private void popolaDatiMancantiDaIDAZI()
		{

			bloccoRecuperoRapLeg = "NO";
			noSaveDB = true;

			// Dim strSQL As String = "select a.id, a.cfAzienda from TEMP_AZI_SPOT_SITAR a where isnull(a.esito,0) = 0 and len(cfAzienda) = 11 order by 1 "
			// Dim connectionString As String = "Password=YMZGG4DHOI44T78;Persist Security Info=True;User ID=usrAFLink_RER;Initial Catalog=AFLink_RER;Data Source=VM396SRV\VM396SRV,1435"

			// Dim strSQL As String = "select a.id, a.cfAzienda from TEMP_AZI_SPOT_SITAR a where isnull(a.esito,0) = 0 and len(cfAzienda) = 11 order by 1"
			// Dim strSQL As String = "select a.id, a.cfAzienda from TEMP_AZI_SPOT_SITAR a where esito is null order by 1"

			string strSQL = "select a.id, a.cfAzienda from TEMP_AZI_SPOT_SITAR a where errore = 'Riferimento a un oggetto non impostato su un''istanza di oggetto.' order by 1";

			string connectionString = @"Password=AFS.user!;Persist Security Info=True;User ID=afsuser;Initial Catalog=AFLink_PA_Dev;Data Source=172.16.0.103\afsse103";

			var db = new ParixClient.Db(connectionString);
			var db2 = new ParixClient.Db(connectionString);

			string output = string.Empty;

			if (db.init() & db2.init())
			{

				var sqlComm = new SqlCommand(strSQL, db.sqlConn);
				var r = sqlComm.ExecuteReader();

				while (r.Read())
				{

					int id = Convert.ToInt32(r[0].ToString());
					string cf = r[1].ToString();

					int esito = 0;
					string numeroCivico = "SNC"; // -- senza numero civico
					string NomeRapLeg = "";
					string CognomeRapLeg = "";
					string CFRapLeg = "";
					string errore = "";

					try
					{

						output = "";
						output = getParixInfo(cf, "ADRIER_IMPORT", connectionString, "1");

						if (!string.IsNullOrEmpty(output))
						{

							esito = 0;
							errore = output;
						}

						else
						{

							esito = 1;
							errore = "";

							if (!string.IsNullOrEmpty(datiRegistroImprese["aziNumeroCivico"].ToString()))
							{
								numeroCivico = datiRegistroImprese["aziNumeroCivico"].ToString();
							}

							NomeRapLeg = datiRegistroImprese["NomeRapLeg"].ToString();
							CognomeRapLeg = datiRegistroImprese["CognomeRapLeg"].ToString();
							CFRapLeg = datiRegistroImprese["CFRapLeg"].ToString();

						}
					}

					catch (Exception ex)
					{
						esito = 0;
						errore = ex.Message;
					}

					string strSQL2 = $"UPDATE TEMP_AZI_SPOT_SITAR SET esito = {esito}, numeroCivico = '{numeroCivico.Replace("'", "''")}', NomeRapLeg = '{NomeRapLeg.Replace("'", "''")}', CognomeRapLeg = '{CognomeRapLeg.Replace("'", "''")}',CFRapLeg = '{CFRapLeg.Replace("'", "''")}', errore = '{errore.Replace("'", "''")}' WHERE id = {id}";

					db2.execSqlNoTransaction(strSQL2);

				}

			}

			db.close();
			db2.close();

		}


		// ITERIAMO SU TUTTI GLI ESTREMI IMPRESA RITORNATI E PRENDIAMO IL PRIMO ESTREMO PRIVO DEL FLAG DI CESSAZIONE E CON IL NUMERO REA VALORIZZATO
		// Questo presuppone che non troveremo mai più estremi non cessati e con numero rea valorizzato, altrimenti verrebbe dato per buono il primo dell’elenco.

		// -- MOD. 16/02/2021 : Dobbiamo tenere conto dei rari casi in cui il dettaglio ridotto ci riporta N estremi impresa tutti non cessati e anche con i REA assegnati.
		// --                     . non va più bene che prendiamo il primo estremo impresa valido, ma li adesso li prendiamo tutti ( estremi non cessati e con numero rea )
		// --                     . per poi utilizzarli sul chiamante per effettuare su tutti il dettaglio estremo e poi utilizzare solo quello che ritorna risultati

		private ArrayList getEstremoImpresaAttivo(XmlDocument m_xmld) // As XmlNode
		{
			XmlNodeList m_nodelist = null;

			var listaNodi = new ArrayList();

			m_nodelist = m_xmld.SelectNodes("/RISPOSTA/DATI/LISTA_IMPRESE/ESTREMI_IMPRESA");

			foreach (XmlNode nodo in m_nodelist)
			{

				if (nodo.SelectNodes("./DATI_ISCRIZIONE_REA/CESSAZIONE").Count == 0)
				{

					try
					{

						string nRea = nodo.SelectSingleNode("./DATI_ISCRIZIONE_REA/NREA").InnerText;

						if (!string.IsNullOrEmpty(nRea))
						{
							// Return nodo
							listaNodi.Add(nodo);
						}
					}

					catch (Exception ex)
					{

					}

				}

			}

			if (listaNodi.Count > 0)
			{
				return listaNodi;
			}
			else
			{
				return null;
			}

		}

		private XmlNode oldGetEstremoImpresaAttivo(XmlDocument m_xmld)
		{

			// -- recupero le date aggiornamento delle N imprese ritornate filtrando i dati rea con sede legale a SI
			string dataUltimoAggiornamento = "19000101"; // 01/01/1900
			XmlNodeList m_nodelist = null;
			XmlNode nodo = null;
			XmlNode tmpNodo = null;

			m_nodelist = m_xmld.SelectNodes("/RISPOSTA/DATI/LISTA_IMPRESE/ESTREMI_IMPRESA/DATI_ISCRIZIONE_REA[FLAG_SEDE = 'SI']/DT_ULT_AGGIORNAMENTO");

			try
			{

				tmpNodo = m_nodelist[0].Clone();

				foreach (XmlNode currentNodo in m_nodelist)
				{
					nodo = currentNodo;

					try
					{
						// -- se il nodo trovato ha una data di aggiornamento dei dati rea maggiore dei precedenti
						if (!string.IsNullOrEmpty(dataUltimoAggiornamento) && string.Compare(nodo.InnerText, dataUltimoAggiornamento, false) > 0)
						{

							dataUltimoAggiornamento = nodo.InnerText;
							tmpNodo = nodo;

						}
					}

					catch (Exception ex)
					{

					}

				}

				// -- una volta ottenuto il nodo corretto risalgo di due livelli per partire dal livello ESTREMI_IMPRESA
				nodo = tmpNodo.ParentNode.ParentNode;
			}

			catch (Exception ex)
			{

				nodo = m_xmld.SelectNodes("/RISPOSTA/DATI/LISTA_IMPRESE/ESTREMI_IMPRESA")[0];

			}

			return nodo;

		}

	}
}