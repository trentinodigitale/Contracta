using Microsoft.VisualBasic;
using Microsoft.VisualBasic.CompilerServices;
using ParixClient.it.lepida.adrier;
using System.Xml;
using eProcurementNext.CommonModule;
using System.ServiceModel;
using eProcurementNext.Razor.RegistroImprese;

namespace eProcurementNext.RegistroImprese
{

	public class ClasseParixClient : IParixClient
	{
		// Dim codFiscale As String
		private string userUlExtraRegionali;
		private string pswdUlExtraRegionali;
		private string bloccoRecuperoRapLeg;

        private DebugTrace dt = new DebugTrace();

        private string endPointParix = "";

		public ClasseParixClient()
		{
			//userUlExtraRegionali = ParixClient.My.MySettingsProperty.Settings.parix_userid;
			//pswdUlExtraRegionali = ParixClient.My.MySettingsProperty.Settings.parix_pwd;
			//bloccoRecuperoRapLeg = ParixClient.My.MySettingsProperty.Settings.non_recuperare_rapleg;

			//ConfigurationServices.GetKey("RegistroImprese:")

			//userUlExtraRegionali = ConfigurationServices.GetKey("RegistroImprese:ADRIER:username"); // ConfigurationSettings.AppSettings("parix_userid");
			////pswdUlExtraRegionali = ConfigurationSettings.AppSettings("parix_pwd");
			////bloccoRecuperoRapLeg = ConfigurationSettings.AppSettings("non_recuperare_rapleg");

			//Console.Write("UserId:" + userUlExtraRegionali);
			//Console.Write("Pwd:" + pswdUlExtraRegionali);
			//Console.Write("bloccoRecuperoRapLeg:" + bloccoRecuperoRapLeg);

		}

		private string ricercaImpresaPerDenominazione(string ragSoc)
		{
			string outputXml = string.Empty;

			RicercaImpreseClient client = new RicercaImpreseClient();
			client.Endpoint.Address = new EndpointAddress(endPointParix);

			outputXml = client.RicercaImpresePerDenominazioneAsync(ragSoc, "", userUlExtraRegionali, pswdUlExtraRegionali).Result;

			return outputXml;

		}

		//private string dettaglioUnitaLocaliImpresa(string cciaa, string nrea)
		//{
		//    string outputXml = string.Empty;

		//    RicercaImpreseClient client = new RicercaImpreseClient();
		//    client.Endpoint.Address = new EndpointAddress(endPointParix);


		//    outputXml = client.DettaglioUnitaLocaliImpresaAsync(cciaa, nrea, "", userUlExtraRegionali, pswdUlExtraRegionali).Result;

		//    //Console.Write(outputXml);

		//    return outputXml;

		//}

		//private string dettaglioUnitaLocaleImpresa(string cciaa, string nrea, string proLocalizzazione)
		//{
		//    string outputXml = string.Empty;

		//    //var client = new ParixClient.emiliaromagna.servizicner.ICRSimpleWSImplService();

		//    //if (!string.IsNullOrEmpty(endPointParix))
		//    //{
		//    //    client.Url = endPointParix;
		//    //}

		//    //// outputXml = client.DettaglioUnitaLocaliImpresa(cciaa, nrea, "", userUlExtraRegionali, pswdUlExtraRegionali)
		//    //outputXml = client.DettaglioUnitaLocaleImpresa(cciaa, nrea, proLocalizzazione, "", userUlExtraRegionali, pswdUlExtraRegionali);


		//    //Console.Write(outputXml);

		//    return outputXml;

		//}


		private string ricercaImpresa(string codFiscale)
		{
			string outputXml = string.Empty;

			RicercaImpreseClient client = new RicercaImpreseClient();
			client.Endpoint.Address = new EndpointAddress(endPointParix);

			outputXml = client.RicercaImpreseNonCessatePerCodiceFiscaleAsync(codFiscale, "", userUlExtraRegionali, pswdUlExtraRegionali).Result;

			return outputXml;

		}

		private string ricercaImpresaTotale(string codFiscale)
		{
			string outputXml = string.Empty;

			RicercaImpreseClient client = new RicercaImpreseClient();
			client.Endpoint.Address = new EndpointAddress(endPointParix);
			outputXml = client.RicercaImpresePerCodiceFiscaleAsync(codFiscale, "", userUlExtraRegionali, pswdUlExtraRegionali).Result;
			return outputXml;

		}

		//private string ricercaPersonePerCodiceFiscale(string cf, string codiceCarica)
		//{
		//    string outputXml = string.Empty;

		//    //var client = new ParixClient.emiliaromagna.servizicner.ICRSimpleWSImplService();

		//    //if (!string.IsNullOrEmpty(endPointParix))
		//    //{
		//    //    client.Url = endPointParix;
		//    //}


		//    RicercaImpreseClient client = new RicercaImpreseClient();
		//    client.Endpoint.Address = new EndpointAddress(endPointParix);


		//    outputXml = AsyncHelper.RunSync(() => client.RicercaPersonePerCodiceFiscaleAsync(cf, codiceCarica, userUlExtraRegionali, pswdUlExtraRegionali));

		//    //Console.Write(outputXml);

		//    return outputXml;
		//}

		private string dettaglioImpresa(string CCIAA, string numeroRea)
		{
			string outputXml = string.Empty;
			RicercaImpreseClient client = new RicercaImpreseClient();
			client.Endpoint.Address = new EndpointAddress(endPointParix);

			outputXml = client.DettaglioCompletoImpresaAsync(CCIAA, numeroRea, "", userUlExtraRegionali, pswdUlExtraRegionali).Result;
			return outputXml;

		}

		public string getParixInfo(string cf, string sessionId, string connectionString, string extra = "")
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

			endPointParix = ParixClient.Utils.getSYS(connectionString, "PARIX_END_POINT");

            dt.Write($"REGISTRO_IMPRESA - CF: {cf} - recuperato endPointParix da SYS {endPointParix}");

            if (string.IsNullOrEmpty(endPointParix))
			{
				endPointParix = ConfigurationServices.GetKey("RegistroImprese:PARIX:wsdl");
                dt.Write($"REGISTRO_IMPRESA - CF: {cf} - recuperato endPointParix da WSDL {endPointParix}");
            }

			string tmpAccountParix = ParixClient.Utils.getSYS(connectionString, "PARIX_ACCOUNT");

			if (!string.IsNullOrEmpty(tmpAccountParix))
			{

				string[] vettAccParix = tmpAccountParix.Split("@@@");
				userUlExtraRegionali = vettAccParix[0];
				pswdUlExtraRegionali = vettAccParix[1];
                dt.Write($"REGISTRO_IMPRESA - CF: {cf} -credenziali recuperate da SYS PARIX_ACCOUNT {endPointParix}");
            }
			else
			{
				userUlExtraRegionali = ConfigurationServices.GetKey("RegistroImprese:PARIX:username");
				pswdUlExtraRegionali = ConfigurationServices.GetKey("RegistroImprese:PARIX:password");
                dt.Write($"REGISTRO_IMPRESA - CF: {cf} -credenziali recuperate da file di configurazione {endPointParix}");
            }


			try
			{
                dt.Write($"REGISTRO_IMPRESA - CF: {cf} - Inizio recupero dettaglio.");
                xmlDettaglioRidotto = ricercaImpresa(cf);            
            }
			catch (Exception ex)
			{
				xmlDettaglioRidotto = "";
				output = "Errore invocazione parix." + ex.Message;
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
                    dt.Write($"REGISTRO_IMPRESA - CF: {cf} - traceXmlParix Dettaglio recuperato FAIL: {ex.Message}");
                }


				m_xmld.LoadXml(xmlDettaglioRidotto);

				esito = m_xmld.SelectNodes("/RISPOSTA/HEADER/ESITO")[0].InnerText;

				if (Strings.UCase(esito) == "OK")
				{
                    dt.Write($"REGISTRO_IMPRESA - CF: {cf} - esito /RISPOSTA/HEADER/ESITO OK");

                    // -- Se troviamo più ESTREMI_IMPRESA
                    // -- Siamo in un caso raro, del tipo che la provincia originale
                    // -- al quale era iscritta l'azienda non esiste più o si è divisa
                    // -- vedi MI e MB

                    if (m_xmld.SelectSingleNode("/RISPOSTA/DATI/LISTA_IMPRESE/@totale").Value == "1")
					{
                        dt.Write($"REGISTRO_IMPRESA - CF: {cf} - caso ESTREMI_IMPRESA multipli");
                        nodo = m_xmld.SelectNodes("/RISPOSTA/DATI/LISTA_IMPRESE/ESTREMI_IMPRESA")[0];
					}

					else
					{
                        dt.Write($"REGISTRO_IMPRESA - CF: {cf} - BLOCCO RECUPERO ULTIMO AGGIORNAMENTO");
                        // -- recupero le date aggiornamento delle N imprese ritornate filtrando i dati rea con sede legale a SI
                        string dataUltimoAggiornamento = "19000101"; // 01/01/1900

						m_nodelist = m_xmld.SelectNodes("/RISPOSTA/DATI/LISTA_IMPRESE/ESTREMI_IMPRESA/DATI_ISCRIZIONE_REA[FLAG_SEDE = 'SI']/DT_ULT_AGGIORNAMENTO");
						tmpNodo = m_nodelist[0].Clone();

						foreach (XmlNode currentNodo in m_nodelist)
						{
							nodo = currentNodo;

							try
							{
								// -- se il nodo trovato ha una data di aggiornamento dei dati rea maggiore dei precedenti
								if (!string.IsNullOrEmpty(dataUltimoAggiornamento) & Operators.CompareString(nodo.InnerText, dataUltimoAggiornamento, false) > 0)
								{

									dataUltimoAggiornamento = nodo.InnerText;
									tmpNodo = nodo;

								}
							}

							catch (Exception ex)
							{

							}

						}

						try
						{

							// -- una volta ottenuto il nodo corretto risalgo di due livelli per partire dal livello ESTREMI_IMPRESA
							nodo = tmpNodo.ParentNode.ParentNode;
						}

						catch (Exception ex)
						{

							nodo = m_xmld.SelectNodes("/RISPOSTA/DATI/LISTA_IMPRESE/ESTREMI_IMPRESA")[0];

						}

					}

					ParixClient.Utils.addFieldToCollection(nodo, "DENOMINAZIONE", dati, "RAGSOC");
					ParixClient.Utils.addFieldToCollection(nodo, "CODICE_FISCALE", dati, "codicefiscale");
					ParixClient.Utils.addFieldToCollection(nodo, "PARTITA_IVA", dati, "PIVA");

					try
					{
						// -- aggiungere la forma giuridica decodificandola da tabella FORMA_GIURIDICA
						formaSoc = nodo.SelectSingleNode("FORMA_GIURIDICA/C_FORMA_GIURIDICA").InnerText;
						nagi = ParixClient.Utils.getDescFormaSoc(formaSoc, connectionString);

						dati.Add("NAGI", nagi);
					}

					catch (Exception ex)
					{
                        dt.Write($"REGISTRO_IMPRESA - CF: {cf} - etDescFormaSoc formaSoc FAIL: {ex.Message}");
                    }

					// -- Se l'esito è ok recupero l'impresa e per prendere i dati REA 
					// -- itero sulla lista delle sedi ritornate da parix 
					// -- ( perchè negli archivi DRIS possono essere presenti imprese plurilocalizzate )
					// -- e   poi vado a prendermi soltanto quella con i dati REA della sede legale dell'azienda
					m_nodelist = nodo.SelectNodes("DATI_ISCRIZIONE_REA");

                    dt.Write($"REGISTRO_IMPRESA - CF: {cf} - Blocco recupero dati impresa");


                    foreach (XmlNode currentNodo1 in m_nodelist)
					{
						nodo = currentNodo1;

						// -- se è la sede legale
						if (ParixClient.Utils.getXPathValue(nodo, "FLAG_SEDE") == "SI")
						{

							dati.Add("IscrCCIAA", nodo.SelectSingleNode("NREA").InnerText);
							dati.Add("SedeCCIAA", nodo.SelectSingleNode("CCIAA").InnerText);
							dati.Add("ANNOCOSTITUZIONE", Strings.Left(nodo.SelectSingleNode("DATA").InnerText, 4)); // <DATA>20041105</DATA>

							break;

						}

					}

					// -- test
					// xmlDettaglioEsteso = dettaglioUnitaLocaliImpresa(dati("SedeCCIAA"), dati("IscrCCIAA"))
					// dettaglioImpresa(dati("SedeCCIAA"), dati("IscrCCIAA"))

					// -- recupero le informazioni estese dell'azienda dopo aver ottenuto cciaa e numeroRea
					xmlDettaglioEsteso = dettaglioImpresa(Conversions.ToString(dati["SedeCCIAA"]), Conversions.ToString(dati["IscrCCIAA"]));

					try
					{
						ParixClient.Utils.traceXmlParix(xmlDettaglioEsteso, "DETTAGLIO_ESTESO", sessionId, cf, connectionString);
					}
					catch (Exception ex)
					{
                        dt.Write($"REGISTRO_IMPRESA - CF: {cf} - traceXmlParix DETTAGLIO_ESTESO FAIL: {ex.Message}");
                    }

					m_xmld.LoadXml(xmlDettaglioEsteso);

					nodo = m_xmld.SelectSingleNode("/RISPOSTA/DATI/DATI_IMPRESA/INFORMAZIONI_SEDE/INDIRIZZO");

					// -- recupero la codifica del comune, se presente, ed in base a questa recupero il resto
					string cod_comune = "";
					string dmv_codComune = "";
					string descComune = "";
					string codeProv = "";
					string descProv = "";
					string[] vet;

                    dt.Write($"REGISTRO_IMPRESA - CF: {cf} - Blocco recupero dati Comune");

                    if (nodo.SelectNodes("C_COMUNE").Count > 0)
					{

						cod_comune = nodo.SelectNodes("C_COMUNE")[0].InnerText;
						if (!String.IsNullOrEmpty(cod_comune))
						{
							ParixClient.Utils.getComune(cod_comune, ref dmv_codComune, ref descComune, connectionString);

							dati.Add("aziLocalitaLeg2", dmv_codComune);
							dati.Add("LOCALITALEG", descComune);

							vet = Strings.Split(dmv_codComune, "-");

							// -- Recupero la provincia a partire dal figlio ( il comune )
							codeProv = Strings.Replace(dmv_codComune, "-" + vet[Information.UBound(vet)], "");

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

                    dt.Write($"REGISTRO_IMPRESA - CF: {cf} - Blocco recupero indirizzo ");

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

					dt.Write($"REGISTRO_IMPRESA - CF: {cf} - Blocco nodo /RISPOSTA/DATI/DATI_IMPRESA/PERSONE_SEDE/PERSONA");

					foreach (XmlNode currentNodo2 in m_nodelist)
					{
						nodo = currentNodo2;

						// -- iteriamo su tutte le persone fino a trovare la PRIMA indicata come rappresentante
						if (nodo.SelectNodes("RAPPRESENTANTE").Count > 0)
						{

							if (Strings.UCase(nodo.SelectNodes("RAPPRESENTANTE")[0].InnerText) == "SI")
							{

								ParixClient.Utils.addFieldToCollection(nodo, "PERSONA_FISICA/NOME", dati, "PERSONA_FISICA_NOME");
								ParixClient.Utils.addFieldToCollection(nodo, "PERSONA_FISICA/COGNOME", dati, "PERSONA_FISICA_COGNOME");
								ParixClient.Utils.addFieldToCollection(nodo, "PERSONA_FISICA/CODICE_FISCALE", dati, "PERSONA_FISICA_CODICE_FISCALE");

								break;

							}

						}

					}

					if (Strings.UCase(bloccoRecuperoRapLeg) != "YES")
					{

						ParixClient.Utils.addFieldToCollection(nodo, "INDIRIZZO_PEC", dati, "PFUEMAIL");

						m_nodelist = m_xmld.SelectNodes("/RISPOSTA/DATI/DATI_IMPRESA/PERSONE_SEDE/PERSONA");

						string carica = "";
						string descCaricaLegRap = "";
						int ruolo = -1;
						int ruoloRapLeg = 10000;
						XmlNode nodoRapLeg = null;

						XmlNodeList cariche = null;

                        dt.Write($"REGISTRO_IMPRESA - CF: {cf} - Blocco nodo /RISPOSTA/DATI/DATI_IMPRESA/PERSONE_SEDE/PERSONA bloccoRecuperoRapLeg != YES");

                        foreach (XmlNode currentNodo3 in m_nodelist)
						{
							nodo = currentNodo3;


							// -- Itero sulle N possibili cariche di ogni persona per vedere se tra queste
							// -- c'è una di rapLeg
							cariche = nodo.SelectNodes("CARICHE/CARICA");

							foreach (XmlNode nodo_carica in cariche)
							{

								// -- se è presente il tag RAPPRESENTANTE che può indicarci facilmenteì
								// -- se la persona è un legale rappresentante o meno usiamo questo
								// -- altrimenti eseguiamo il controllo sui possibili ruoli con i relativi
								// -- pesi che attribuiamo a un rapleg
								// If nodo.SelectNodes("RAPPRESENTANTE").Count > 0 Then

								// If UCase(CStr(getXPathValue(nodo, "RAPPRESENTANTE"))) = "SI" Then

								// nodoRapLeg = nodo.Clone
								// descCaricaLegRap = nodo_carica.SelectSingleNode("DESCRIZIONE").InnerText

								// End If

								// Else

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


								// End If


							}

						}

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

                    dt.Write($"REGISTRO_IMPRESA - CF: {cf} - insertCollectionInDb");
                    ParixClient.Utils.insertCollectionInDb(dati, sessionId, cf, connectionString);
				}


				else // KO
				{

					tipoErrore = m_xmld.SelectNodes("/RISPOSTA/DATI/ERRORE/TIPO")[0].InnerText;
					parixError = m_xmld.SelectNodes("/RISPOSTA/DATI/ERRORE/MSG_ERR")[0].InnerText;

					output = "Errore.[" + tipoErrore + "] - " + parixError;

					ParixClient.Utils.traceXmlParix(output, "ERRORE_DETTAGLIO_RIDOTTO", sessionId, cf, connectionString);

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

		// -- INPUT
		// --   CF : Codice fiscale dell'azienda da cercare
		// -- OUTPUT
		// --   1#emailPecAzienda@dominio.it
		// --   0#MsgDiErrore
		private string getAziEmail(string cf, string connectionString)
		{
			string getAziEmailRet = default;

			string xmlDettaglioRidotto = "";
			string xmlDettaglioEsteso = "";
			var m_xmld = new XmlDocument();
			XmlNodeList m_nodelist = null;
			XmlNode nodo = null;
			XmlNode tmpNodo = null;
			string output = "";              // -- vuoto se non c'è errore. viceversa c'è l'errore
			string esito = "";               // -- esito ritornato da parix
			string tipoErrore = "";          // -- codice di errore parix
			string parixError = "";          // -- msg di errore di parix

			getAziEmailRet = "";
			output = "";

			try
			{

				xmlDettaglioRidotto = ricercaImpresa(cf);

				if (!string.IsNullOrEmpty(xmlDettaglioRidotto))
				{

					m_xmld.LoadXml(xmlDettaglioRidotto);

					esito = m_xmld.SelectNodes("/RISPOSTA/HEADER/ESITO")[0].InnerText;

					if (Strings.UCase(esito) == "OK")
					{

						if (m_xmld.SelectSingleNode("/RISPOSTA/DATI/LISTA_IMPRESE/@totale").Value == "1")
						{

							nodo = m_xmld.SelectNodes("/RISPOSTA/DATI/LISTA_IMPRESE/ESTREMI_IMPRESA")[0];
						}

						else
						{

							// -- recupero le date aggiornamento delle N imprese ritornate filtrando i dati rea con sede legale a SI
							string dataUltimoAggiornamento = "19000101"; // 01/01/1900

							m_nodelist = m_xmld.SelectNodes("/RISPOSTA/DATI/LISTA_IMPRESE/ESTREMI_IMPRESA/DATI_ISCRIZIONE_REA[FLAG_SEDE = 'SI']/DT_ULT_AGGIORNAMENTO");
							tmpNodo = m_nodelist[0].Clone();

							foreach (XmlNode currentNodo in m_nodelist)
							{
								nodo = currentNodo;

								try
								{
									// -- se il nodo trovato ha una data di aggiornamento dei dati rea maggiore dei precedenti
									if (!string.IsNullOrEmpty(dataUltimoAggiornamento) & Operators.CompareString(nodo.InnerText, dataUltimoAggiornamento, false) > 0)
									{

										dataUltimoAggiornamento = nodo.InnerText;
										tmpNodo = nodo;

									}
								}

								catch (Exception ex)
								{

								}

							}

							try
							{

								// -- una volta ottenuto il nodo corretto risalgo di due livelli per partire dal livello ESTREMI_IMPRESA
								nodo = tmpNodo.ParentNode.ParentNode;
							}

							catch (Exception ex)
							{

								nodo = m_xmld.SelectNodes("/RISPOSTA/DATI/LISTA_IMPRESE/ESTREMI_IMPRESA")[0];

							}

						}

						string sedeCCIAA = "";
						string iscrCCIAA = "";
						string strTmpValue = "";

						// -- Se l'esito è ok recupero l'impresa e per prendere i dati REA 
						// -- itero sulla lista delle sedi ritornate da parix 
						// -- ( perchè negli archivi DRIS possono essere presenti imprese plurilocalizzate )
						// -- e   poi vado a prendermi soltanto quella con i dati REA della sede legale dell'azienda
						m_nodelist = nodo.SelectNodes("DATI_ISCRIZIONE_REA");

						foreach (XmlNode currentNodo1 in m_nodelist)
						{
							nodo = currentNodo1;

							// -- se è la sede legale
							if (ParixClient.Utils.getXPathValue(nodo, "FLAG_SEDE") == "SI")
							{

								iscrCCIAA = nodo.SelectSingleNode("NREA").InnerText;
								sedeCCIAA = nodo.SelectSingleNode("CCIAA").InnerText;
								break;

							}

						}

						// -- recupero le informazioni estese dell'azienda dopo aver ottenuto cciaa e numeroRea
						xmlDettaglioEsteso = dettaglioImpresa(sedeCCIAA, iscrCCIAA);

						try
						{
							ParixClient.Utils.traceXmlParixImport(xmlDettaglioEsteso, cf, connectionString);
						}
						catch (Exception ex)
						{
						}

						m_xmld.LoadXml(xmlDettaglioEsteso);

						nodo = m_xmld.SelectSingleNode("/RISPOSTA/DATI/DATI_IMPRESA/INFORMAZIONI_SEDE/INDIRIZZO");

						m_nodelist = nodo.SelectNodes("INDIRIZZO_PEC");

						// -- aggiunto l'elemento alla collezione se l'espressione xpath mi ha ritornato qualcosa
						if (m_nodelist.Count > 0)
						{
							strTmpValue = m_nodelist[0].InnerText;
						}

						if (string.IsNullOrEmpty(strTmpValue))
						{
							output = "0#Email non presente";
						}
						else
						{
							output = "1#" + strTmpValue;
						}

						m_xmld = null;
						m_nodelist = null;
					}


					else
					{

						// tipoErrore = m_xmld.SelectNodes("/RISPOSTA/DATI/ERRORE/TIPO")(0).InnerText
						tipoErrore = "";
						parixError = m_xmld.SelectNodes("/RISPOSTA/DATI/ERRORE/MSG_ERR")[0].InnerText;

						m_xmld = null;

						output = "0#Errore. - " + parixError;

					} // --If UCase(esito) = "OK" Then
				}

				else
				{

					output = "0#Errore.Xml di output vuoto.";

				}
			}


			catch (Exception ex)
			{
				m_xmld = null;
				xmlDettaglioRidotto = "";
				output = "0#Errore invocazione parix." + ex.Message;
			}


			getAziEmailRet = output;
			return getAziEmailRet;


		}

		//private void rettificaAziendeParix(string connectionString)
		//{

		//    string strSQL = "select id, aziRagioneSociale, azipartitaiva FROM PARIX_RETTIFICA_AZIENDE order by 1";

		//    var db = new ParixClient.Db(connectionString);
		//    var db2 = new ParixClient.Db(connectionString);

		//    if (db.init() == true & db2.init())
		//    {

		//        var sqlComm = new System.Data.SqlClient.SqlCommand(strSQL, db.sqlConn);
		//        var r = sqlComm.ExecuteReader();

		//        while (r.Read())
		//        {

		//            int id = Conversions.ToInteger(r[0]);
		//            string ragSoc = Conversions.ToString(r[1]);
		//            string piva = Conversions.ToString(r[2]);

		//            string cf = "";
		//            string bFound = "0";

		//            string errore = "";
		//            string outputXML = "";

		//            try
		//            {

		//                piva = Strings.Replace(Strings.UCase(piva), "IT", "");

		//                outputXML = ricercaImpresaPerDenominazione(ragSoc);

		//                var m_xmld = new XmlDocument();
		//                XmlNodeList m_nodelist = null;

		//                m_xmld.LoadXml(outputXML);

		//                m_nodelist = m_xmld.SelectNodes("//ESTREMI_IMPRESA");

		//                foreach (XmlNode nodo in m_nodelist)
		//                {

		//                    if ((ParixClient.Utils.getXPathValue(nodo, "PARTITA_IVA") ?? "") == (piva ?? ""))
		//                    {

		//                        cf = ParixClient.Utils.getXPathValue(nodo, "CODICE_FISCALE");
		//                        bFound = "1";

		//                    }

		//                }
		//            }


		//            catch (Exception ex)
		//            {
		//                errore = ex.Message;
		//            }

		//            string strSQL2 = "UPDATE PARIX_RETTIFICA_AZIENDE SET outputParix = N'" + Strings.Replace(outputXML, "'", "''") + "',CF_Parix = '" + Strings.Replace(cf, "'", "''") + "',bFound = '" + bFound + "',errore = '" + errore + "' WHERE id = " + id.ToString();

		//            db2.execSqlNoTransaction(strSQL2);


		//        }

		//    }

		//    db.close();
		//    db2.close();

		//}

		//private void rettificaAziendeLepida2(string connectionString)
		//{

		//    // Dim strSQL As String = "select id, azipartitaiva,codice_fiscale FROM PARIX_RETTIFICA_AZIENDE where bFound = 0 and outputParix like '%<TIPO>CF_PI_errato</TIPO>%' order by 1"
		//    string strSQL = "select id, codice_fiscale FROM PARIX_RETTIFICA_AZIENDE where bFound = 0 and outputParix like '%<TIPO>provider_error</TIPO>%' order by 1";

		//    // Dim strSQL As String = "select id, codice_fiscale from PARIX_RETTIFICA_AZIENDE  where errore = 'Riferimento a un oggetto non impostato su un''istanza di oggetto.' and bfound = 0"
		//    // Dim strSQL As String = "select id, azipartitaiva, codice_fiscale from PARIX_RETTIFICA_AZIENDE  where errore = 'Riferimento a un oggetto non impostato su un''istanza di oggetto.' and bfound = 0"

		//    var db = new ParixClient.Db(connectionString);
		//    var db2 = new ParixClient.Db(connectionString);

		//    if (db.init() == true & db2.init())
		//    {

		//        var sqlComm = new System.Data.SqlClient.SqlCommand(strSQL, db.sqlConn);
		//        var r = sqlComm.ExecuteReader();

		//        while (r.Read())
		//        {

		//            int id = Conversions.ToInteger(r[0]);
		//            string cf = Conversions.ToString(r[1]);

		//            string bFound = "0";
		//            string cessato = "0";
		//            string errore = "";
		//            string outputXML = "";
		//            string causale = "";
		//            string dataCessazione = "";

		//            try
		//            {

		//                int numRetry = 0;
		//                var m_xmld = new XmlDocument();
		//                XmlNodeList m_nodelist = null;

		//                if (strSQL.Contains("CF_PI_errato"))
		//                {
		//                    cf = Strings.Replace(Strings.UCase(cf), "IT", "");
		//                }


		//                do
		//                {

		//                    numRetry += 1;

		//                    // outputXML = ricercaImpresaPerDenominazione(ragSoc)
		//                    // outputXML = ricercaImpresaTotale(cf)
		//                    outputXML = lepidaRricercaImpresaPerCF(cf);

		//                    // If outputXML.Contains("<MSG_ERR>NESSUNA IMPRESA TROVATA</MSG_ERR>") Or outputXML.Contains("<TIPO>IMP_occorrenza_0</TIPO>") Or outputXML.Contains("<TIPO>provider_error</TIPO>") Then
		//                    if (outputXML.Contains("<ESITO>KO</ESITO>"))
		//                    {
		//                        bFound = "0";
		//                    }
		//                    else
		//                    {
		//                        bFound = "1";
		//                    }
		//                }

		//                while (outputXML.Contains("<TIPO>provider_error</TIPO>") & numRetry < 5);

		//                if (bFound == "0")
		//                {
		//                    cf = "";
		//                }


		//                m_xmld.LoadXml(outputXML);

		//                cf = m_xmld.SelectNodes("//CODICE_FISCALE")[0].InnerText;

		//                m_nodelist = m_xmld.SelectNodes("//CESSAZIONE");

		//                foreach (XmlNode nodo in m_nodelist)
		//                {

		//                    cessato = "1";

		//                    causale = causale + ParixClient.Utils.getXPathValue(nodo, "CAUSALE") + " - ";
		//                    dataCessazione = dataCessazione + ParixClient.Utils.getXPathValue(nodo, "DT_CESSAZIONE") + " - ";

		//                }
		//            }

		//            catch (Exception ex)
		//            {
		//                errore = ex.Message;
		//            }

		//            string strSQL2 = "UPDATE PARIX_RETTIFICA_AZIENDE SET cessato = " + cessato + ",causaleCessazione = '" + Strings.Replace(causale, "'", "''") + "',dataCessazione = '" + Strings.Replace(dataCessazione, "'", "''") + "',   outputParix = N'" + Strings.Replace(outputXML, "'", "''") + "',CF_Parix = '" + Strings.Replace(cf, "'", "''") + "',bFound = '" + bFound + "',errore = '" + Strings.Replace(errore, "'", "''") + "' WHERE id = " + id.ToString();

		//            db2.execSqlNoTransaction(strSQL2);


		//        }

		//    }

		//    db.close();
		//    db2.close();

		//}

		//private void rettificaAziendeParix3(string connectionString)
		//{

		//    string strSQL = "select id, aziRagioneSociale,azipartitaiva from PARIX_RETTIFICA_AZIENDE where bfound = 0 and ( outputParix like '%<MSG_ERR>NESSUNA IMPRESA TROVATA</MSG_ERR>%' or outputParix = '')";

		//    var db = new ParixClient.Db(connectionString);
		//    var db2 = new ParixClient.Db(connectionString);

		//    if (db.init() == true & db2.init())
		//    {

		//        var sqlComm = new System.Data.SqlClient.SqlCommand(strSQL, db.sqlConn);
		//        var r = sqlComm.ExecuteReader();

		//        while (r.Read())
		//        {

		//            int id = Conversions.ToInteger(r[0]);
		//            string ragSoc = Conversions.ToString(r[1]);
		//            string piva = Conversions.ToString(r[2]);

		//            string cf = "";
		//            string bFound = "0";

		//            string errore = "";
		//            string outputXML = "";

		//            try
		//            {

		//                piva = Strings.Replace(Strings.UCase(piva), "IT", "");

		//                if (ragSoc.Contains(" "))
		//                {

		//                    object[] vet = ragSoc.Split(' ');
		//                    ragSoc = Conversions.ToString(vet[0]);

		//                    if (ragSoc.Length <= 3 & Information.UBound(vet) > 0)
		//                    {
		//                        ragSoc = Conversions.ToString(Operators.ConcatenateObject(ragSoc + " ", vet[1]));
		//                    }

		//                    if (ragSoc.Length <= 6 & Information.UBound(vet) > 1)
		//                    {
		//                        ragSoc = Conversions.ToString(Operators.ConcatenateObject(ragSoc + " ", vet[2]));
		//                    }


		//                }

		//                outputXML = ricercaImpresaPerDenominazione(ragSoc);

		//                var m_xmld = new XmlDocument();
		//                XmlNodeList m_nodelist = null;

		//                m_xmld.LoadXml(outputXML);

		//                m_nodelist = m_xmld.SelectNodes("//ESTREMI_IMPRESA");

		//                foreach (XmlNode nodo in m_nodelist)
		//                {

		//                    if ((ParixClient.Utils.getXPathValue(nodo, "PARTITA_IVA") ?? "") == (piva ?? ""))
		//                    {

		//                        cf = ParixClient.Utils.getXPathValue(nodo, "CODICE_FISCALE");
		//                        bFound = "1";

		//                    }

		//                }
		//            }


		//            catch (Exception ex)
		//            {
		//                errore = ex.Message;
		//            }

		//            string strSQL2 = "UPDATE PARIX_RETTIFICA_AZIENDE SET outputParix = N'" + Strings.Replace(outputXML, "'", "''") + "',CF_Parix = '" + Strings.Replace(cf, "'", "''") + "',bFound = '" + bFound + "',errore = '" + Strings.Replace(errore, "'", "''") + "' WHERE id = " + id.ToString();

		//            db2.execSqlNoTransaction(strSQL2);


		//        }

		//    }

		//    db.close();
		//    db2.close();

		//}

		//private void rettificaAziendeLepidaPIVA(string connectionString)
		//{

		//    string strSQL = "select id, azipartitaiva from PARIX_RETTIFICA_AZIENDE where bfound = 0";

		//    var db = new ParixClient.Db(connectionString);
		//    var db2 = new ParixClient.Db(connectionString);

		//    if (db.init() == true & db2.init())
		//    {

		//        var sqlComm = new System.Data.SqlClient.SqlCommand(strSQL, db.sqlConn);
		//        var r = sqlComm.ExecuteReader();

		//        while (r.Read())
		//        {

		//            int id = Conversions.ToInteger(r[0]);
		//            string piva = Conversions.ToString(r[1]);

		//            string cf = "";
		//            string bFound = "0";

		//            string errore = "";
		//            string outputXML = "";

		//            try
		//            {

		//                piva = Strings.Replace(Strings.UCase(piva), "IT", "");

		//                outputXML = lepidaRricercaImpresaPerCF(piva);

		//                var m_xmld = new XmlDocument();
		//                XmlNodeList m_nodelist = null;

		//                m_xmld.LoadXml(outputXML);

		//                m_nodelist = m_xmld.SelectNodes("//ESTREMI_IMPRESA");

		//                foreach (XmlNode nodo in m_nodelist)
		//                {

		//                    if ((ParixClient.Utils.getXPathValue(nodo, "PARTITA_IVA") ?? "") == (piva ?? ""))
		//                    {

		//                        cf = ParixClient.Utils.getXPathValue(nodo, "CODICE_FISCALE");
		//                        bFound = "1";

		//                    }

		//                }
		//            }


		//            catch (Exception ex)
		//            {
		//                errore = ex.Message;
		//            }

		//            string strSQL2 = "UPDATE PARIX_RETTIFICA_AZIENDE SET OLD = 0, outputParix = N'" + Strings.Replace(outputXML, "'", "''") + "',CF_Parix = '" + Strings.Replace(cf, "'", "''") + "',bFound = '" + bFound + "',errore = '" + Strings.Replace(errore, "'", "''") + "' WHERE id = " + id.ToString();

		//            db2.execSqlNoTransaction(strSQL2);


		//        }

		//    }

		//    db.close();
		//    db2.close();

		//}

		//private string lepidaRricercaImpresaPerCF(string piva)
		//{

		//    RicercaImpreseClient client = new RicercaImpreseClient();
		//    client.Endpoint.Address = new EndpointAddress(endPointParix);
		//    string outputXml;

		//    outputXml = client.RicercaImpresePerCodiceFiscaleAsync(piva, "", userUlExtraRegionali , pswdUlExtraRegionali).Result;

		//    Console.Write(outputXml);

		//    return outputXml;

		//}


	}
}