using CsvHelper;
using CsvHelper.Configuration;
using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.IO.Compression;
using System.Net;
using System.Net.Http;
using System.Reflection;
using System.Security.Authentication;
using System.Text;
using System.Web.Http;
using System.Web.Services.Description;
using System.Xml;


namespace INIPEC_WS.Controllers
{
    public class XMLScaricaPecresponse
    {
        public string Esito { get; set; }
        public string CodiceErrore { get; set; }
        public string NomeFile { get; set; }
    }

    public class CSVResponse
    {
        public string Input { get; set; }
        public string EsitoPecImpresa { get; set; }
        public string PecImpresa { get; set; }
        public string DescrizioneEsitoPec { get; set; }
    }

    public class CSVResponseMapByName : ClassMap<CSVResponse>
    {
        public CSVResponseMapByName()
        {
            Map(p => p.Input).Name("INPUT");
            Map(p => p.EsitoPecImpresa).Name("ESITO PEC IMPRESA");
            Map(p => p.PecImpresa).Name("PEC IMPRESA");
            Map(p => p.DescrizioneEsitoPec).Name("DESCRIZIONE ESITO PEC IMPRESA");
        }
    }

    public class ScaricaPecController : ApiController
    {
        public const SslProtocols _Tls12 = (SslProtocols)0x00000C00;
        public const SecurityProtocolType Tls12 = (SecurityProtocolType)_Tls12;

        public void TemplateIntegrationRequest()
        {
            ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };
        }

        [HttpGet]
        public void ScaricaDatiPec(string ID, string OPERATION)
        {
            /* Inzializzo variabili */
            string strCause = string.Empty;
            string pathZip = string.Empty;
            string pathCsv = string.Empty;
            string txtName = string.Empty;
            string zipName = string.Empty;
            string filePath = string.Empty;
            string soapResponseEnvelope = string.Empty;
            string pathMain = string.Empty;
            string pathFull = string.Empty;
            string partialPath = string.Empty;
            string idRichiestaINIPEC = string.Empty;
            string idRow = string.Empty;
            string operazioneRichiesta = string.Empty;
            int retry = 6;
            int idDoc;
            string XMLbody = string.Empty;
            string statoRichiesta = string.Empty;
            string inputWS = string.Empty;
            string outputWS = string.Empty;
            string sysPath = "SYS_PathFolderAllegati";
            int testIDnumber = 0;
            string strSQL = string.Empty;
            string basicUsername = string.Empty;
            string basicPassword = string.Empty;
            string connectionString = ConfigurationManager.AppSettings["db.conn"];

            /* Istanzio oggetti */
            HttpResponseMessage response = new HttpResponseMessage();
            SqlCommand cmd1 = new SqlCommand();
            SqlConnection sqlConn = null;
            SqlDataReader rs = null;
            XMLScaricaPecresponse xmlResponse = new XMLScaricaPecresponse();

            /* Eseguo controlli sui dati forniti in input alla chiamata */
            if (ID == "")
                throw new Exception("Parametro ID obbligatorio");

            bool testID = Int32.TryParse(ID, out testIDnumber);

            if (!testID)
            {
                throw new Exception("Parametro ID non valido");
            }

            idRow = ID;

            try
            {
                /* Recupero parametri da Configuration Manager */
                strCause = "Recupero i parametri dal Configuration Manager";
                string tipoRichiesta = ConfigurationManager.AppSettings["InfoCamere.ScaricaPec.TipoRichiesta"];
                string indirizzoWS = ConfigurationManager.AppSettings["InfoCamere.Indirizzo_WS"];
                string indirizzoClient = ConfigurationManager.AppSettings["InfoCamere.Client"];
                string soapAction = ConfigurationManager.AppSettings["InfoCamere.SOAPAction.ScaricaPec"];
                string endPoint = ConfigurationManager.AppSettings["InfoCamere.Endpoint"];
                partialPath = ConfigurationManager.AppSettings["InfoCamere.ScaricaPec.FilePath"];


                /*Leggo valore path file tmp da SYS */
                strCause = "Ottengo valore della directory dove andare a scrivere i file temporanei";
                strSQL = @"select 
                                DZT_VALUEDEF 
                           FROM 
                                LIB_DICTIONARY WITH(NOLOCK) 
                           WHERE 
                                DZT_NAME = @sysPath";

                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();
                    using (cmd1 = new SqlCommand(strSQL, connection))
                    {
                        cmd1.Parameters.AddWithValue("@sysPath", sysPath);
                        rs = cmd1.ExecuteReader();

                        if (rs.Read())
                        {
                            pathMain = (string)rs["DZT_VALUEDEF"];
                            rs.Close();
                        }
                        else
                        {
                            rs.Close();
                            throw new Exception("Fallito il recupero dell'idRichiesta");
                        }
                    }

                    pathMain = pathMain.Replace("\\", "/");


#if DEBUG
                    pathMain = ConfigurationManager.AppSettings["InfoCamere.mainPath"];
                    basicUsername = ConfigurationManager.AppSettings["InfoCamere.BasicUsername"]; 
                    basicPassword = ConfigurationManager.AppSettings["InfoCamere.BasicPassword"];
#endif


                    strCause = "Recupero dal documento di configurazioni i valori di username e password per i serivizi INIPEC";
                    strSQL = @" select 
                                    b.ClientID as ClientID, 
                                    b.ClientSecret as ClientSecret
                                    from CTL_DOC a
                                     inner join [dbo].[Document_Parametri_Controlli_INIPEC] b on a.id = b.idHeader
                                    where tipodoc = 'PARAMETRI_CONTROLLO_INIPEC' and statofunzionale = 'Confermato'
                                    and deleted = 0";

                    using (cmd1 = new SqlCommand(strSQL, connection))
                    {
                        cmd1.Parameters.AddWithValue("@sysPath", sysPath);
                        rs = cmd1.ExecuteReader();

                        if (rs.Read())
                        {
                            basicUsername = (string)rs["ClientID"];
                            basicPassword = (string)rs["ClientSecret"];
                            rs.Close();
                        }
                        else
                        {
                            rs.Close();
                            throw new Exception("Fallito il recupero di clientID e ClientSecret");
                        }
                    }


                    /* SEZIONE PER IL TEST: FORZO L'ERRORE SE UN PARAMETRO SULLA CTL_PARAMETRI è VALORIZZATO A 1 */
                    strSQL = @" select 
                                    Valore 
                                from CTL_Parametri 
                                where Contesto = 'GESTIONE_INIPEC' 
                                and Oggetto = 'INIPEC' 
                                and Proprieta = 'GeneraErroreMail'";
                    using (cmd1 = new SqlCommand(strSQL, connection))
                    {
                        cmd1.Parameters.AddWithValue("@sysPath", sysPath);
                        rs = cmd1.ExecuteReader();

                        if (rs.Read())
                        {
                            int generateError = Convert.ToInt32((string)rs["Valore"]);
                            rs.Close();

                            if (generateError == 1)
                                throw new Exception("ERRORE DI TEST GENERATO VOLONTARIAMENTE PER VERIFICARE IL CORRETTO INVIO E-MAIL.");
                        }
                    }


                    /* Avanzo lo statoRichiesta a "InGestione
                     * 
                     * " */
                    strCause = "Faccio avanzare lo statoRichiesta della Services_Integration_Request ad 'InGestione'";
                    strSQL = @"UPDATE Services_Integration_Request 
                                set 
                                    statoRichiesta = @statoRichiesta, 
                                    DataExecuted = getDate(), 
                                    numRetry = isnull(numRetry,0) + 1
                                where 
                                    idRow = @idRow";

                    using (cmd1 = new SqlCommand(strSQL, connection))
                    {
                        statoRichiesta = "InGestione";
                        cmd1.Parameters.AddWithValue("@statoRichiesta", statoRichiesta);
                        cmd1.Parameters.AddWithValue("@inputWS", inputWS);
                        cmd1.Parameters.AddWithValue("@outputWS", outputWS);
                        cmd1.Parameters.AddWithValue("@idRow", idRow);
                        cmd1.ExecuteNonQuery();
                    }

                    /* Recupero l'identificativo del documento di richiesta */
                    strCause = "Recupero l'identificativo del documento di richiesta";
                    strSQL = @" select 
                                    idRichiesta, 
                                    numRetry 
                                from 
                                    Services_Integration_Request a with(nolock) 
                                where 
                                    idRow = @idRow";

                    using (cmd1 = new SqlCommand(strSQL, connection))
                    {
                        cmd1.Parameters.AddWithValue("@idRow", idRow);
                        rs = cmd1.ExecuteReader();

                        if (rs.Read())
                        {
                            idDoc = (int)rs["idRichiesta"];
                            retry = (int)rs["numRetry"];
                            rs.Close();
                        }
                        else
                        {
                            rs.Close();
                            throw new Exception("Fallito il recupero dell'idRichiesta");
                        }
                    }

                    /* Recupero l'identificativo del dato richiesto */
                    strCause = "Recupero l'identificativo del documento di richiesta";
                    strSQL = @" select 
                                    datoRichiesto 
                                from 
                                    Services_Integration_Request a with(nolock) 
                                where 
                                    idRichiesta = @idDoc 
                                    and operazioneRichiesta = @operazioneRichiesta";

                    operazioneRichiesta = "CaricaPec";

                    using (cmd1 = new SqlCommand(strSQL, connection))
                    {
                        cmd1.Parameters.AddWithValue("@idDoc", idDoc);
                        cmd1.Parameters.AddWithValue("@operazioneRichiesta", operazioneRichiesta);
                        rs = cmd1.ExecuteReader();

                        if (rs.Read())
                        {
                            idRichiestaINIPEC = (string)rs["datoRichiesto"];
                            rs.Close();
                        }
                        else
                        {
                            rs.Close();
                            throw new Exception("Fallito il recupero del dato richiesto");
                        }
                    }
                }

                /* Inizializzo le impostazioni di sicurezza del protocolloI */
                strCause = "Inizializzo le impostazioni di sicurezza del protocollo";
                ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };
                ServicePointManager.Expect100Continue = true;
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | (SecurityProtocolType)192 | (SecurityProtocolType)768 | (SecurityProtocolType)3072;

                pathMain = pathMain.Replace("\\", "/");

                /* Compongo il path completo */
                pathFull = $"{pathMain}{partialPath}";

                /* Compongo il body della request */
                strCause = "Compongo il body della request";
                string body =
                @"<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/envelope/"" xmlns:ws=""{Indirizzo_WS}"">
                    <soapenv:Header/>
                    <soapenv:Body>
                        <ws:richiestaScaricoFornituraPec>
                            <tokenRichiestaInfocamere>
                                <tipoRichiesta>{TipoRichiesta}</tipoRichiesta>
                                <idRichiesta>{IdRichiesta}</idRichiesta>
                            </tokenRichiestaInfocamere>
                        </ws:richiestaScaricoFornituraPec>
                    </soapenv:Body>
                </soapenv:Envelope>";

                inputWS = body;

                /* Sosituisco i placeholder nel body con i valori parametrizzati dal configuration manager */
                strCause = "Eseguo il replace dei placeholder nel corpo XML";
                body = body.Replace("{Indirizzo_WS}", indirizzoWS);
                body = body.Replace("{TipoRichiesta}", tipoRichiesta);
                body = body.Replace("{IdRichiesta}", idRichiestaINIPEC);

                string encodedAuth = System.Convert.ToBase64String(Encoding.GetEncoding("ISO-8859-1")
                                                    .GetBytes(basicUsername + ":" + basicPassword));

                /* Setto i parametri per la chiamata al WS */
                strCause = "Eseguo la chiamata al WS";
                var client = new HttpClient();
                var request = new HttpRequestMessage(HttpMethod.Post, $"{indirizzoClient}{endPoint}");
                request.Headers.Add("SOAPAction", soapAction);
                request.Headers.Add("Authorization", $"Basic {encodedAuth}");
                request.Content = new StringContent(body, null, "application/xml");

                /* Eseguo la chiamata */
                response = client.SendAsync(request).Result;
                response.EnsureSuccessStatusCode();

                strCause = "Scrivo nello stream il contenuto della response";
                /* Metto il contenuto nello stream ed estraggo i file contenuti all'interno */
                MultipartMemoryStreamProvider multipart = new MultipartMemoryStreamProvider();
                multipart = response.Content.ReadAsMultipartAsync().Result;

                strCause = "Inizio lavorazione della response";
                soapResponseEnvelope = multipart.Contents[0].ReadAsStringAsync().Result;

                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.LoadXml(soapResponseEnvelope);

                /* Risolvo i namespace del documento */
                var soapNamespace = new XmlNamespaceManager(xmlDoc.NameTable);
                soapNamespace.AddNamespace("soap", ConfigurationManager.AppSettings["InfoCamere.XMLnamespace.soap"]);
                soapNamespace.AddNamespace("ns3", ConfigurationManager.AppSettings["InfoCamere.XMLnamespace.ns3"]);

                /* Creo due nodelist con il percorso dei dati necessari */
                strCause = "Creo le nodelist dell'xml response e assegno i valori alle proprietà di un oggetto";
                XmlNodeList xnListEsito = xmlDoc.SelectNodes("/soap:Envelope/soap:Body/ns3:rispostaScaricoFornituraPec/esito", soapNamespace);
                XmlNodeList xnListFornitura = xmlDoc.SelectNodes("/soap:Envelope/soap:Body/ns3:rispostaScaricoFornituraPec/fornitura", soapNamespace);

                /* Scalando le due nodelist appena generate ottengo i valori necessari per le lavorazioni */
                foreach (XmlNode xn in xnListEsito)
                {
                    xmlResponse.Esito = xn["esito"].InnerText;
                    xmlResponse.CodiceErrore = xn["codiceErrore"].InnerText;
                }

                foreach (XmlNode xn in xnListFornitura)
                {
                    xmlResponse.NomeFile = xn["nomeDocumento"].InnerText;
                }

                if (xmlResponse.Esito == "true")
                {

                    /* Leggo la seocnda parte della response, contenente il file zip con all'interno il CSV dei risultati della lavorazione */
                    strCause = "Leggo il contenuto del CSV";
                    byte[] encodedFile = multipart.Contents[1].ReadAsByteArrayAsync().Result;

                    /* Converto l'allegato della response in Base64 e lo metto nell'output log */
                    outputWS += $" Base64 file .zip (bytearray) -- {Convert.ToBase64String(encodedFile, 0, encodedFile.Length)}";

                    strCause = "Esito letto dalla response 'true': inizio le operazioni di lavorazione";

                    /* Compongo i path */
                    pathZip = pathFull + xmlResponse.NomeFile;
                    pathCsv = pathZip.Replace("zip", "csv");

                    /* Controllo se la cartella di destinazione esiste, altrimenti la creo*/
                    strCause = "Creo la cartella di testo per lavorare i file (se non già presente) e elimino eventuali omonimi già presenti al suo interno.";
                    if (!Directory.Exists(pathFull))
                        Directory.CreateDirectory(pathFull);

                    /* Scrivo il file nel percorso indicato, estraggo il contenuto dallo zip e leggo il contenuto */
                    strCause = $"Creo il file {pathZip}";
                    File.WriteAllBytes(pathZip, encodedFile);

                    /* Controllo se esiste gia un file con lo stesso nome, e in tal caso lo sostituisco */
                    if (File.Exists(pathCsv))
                        File.Delete(pathCsv);

                    /* Estraggo il contenuto dello zip */
                    strCause = "Estraggo il contenuto della cartella compressa";
                    ZipFile.ExtractToDirectory(pathZip, pathFull);

                    strCause = "Inzio la lettura del file CSV";
                    var configuration = new CsvConfiguration(CultureInfo.InvariantCulture)
                    {
                        Encoding = Encoding.UTF8,
                        Delimiter = "~"
                    };
                    using (SqlConnection connection = new SqlConnection(connectionString))
                    {
                        connection.Open();
                        using (var fs = File.Open(pathCsv, FileMode.Open, FileAccess.Read, FileShare.Read))
                        {
                            using (var textReader = new StreamReader(fs, Encoding.UTF8))
                            using (var csv = new CsvReader(textReader, configuration))
                            {
                                /* Classe creata per mappare i nomi delle colonne del CSV con delle nomi custom per le proprietà della classe */
                                csv.Context.RegisterClassMap<CSVResponseMapByName>();
                                var data = csv.GetRecords<CSVResponse>();
                                int rowCounter = 0;

                                /* Itero sul CSV */
                                foreach (var row in data)
                                {
                                    rowCounter++;
                                    strCause = $"Sto per ciclare la riga numero {rowCounter} del CSV, con codice azienda '{row.Input}'";
                                    {
                                        /* A questo punto abbiamo accesso alle singole righe del CSV mappate in base alla classe custom creata sulla base dei campi. */
                                        strSQL = @"UPDATE Document_INIPEC 
                                                     SET 
                                                        dataUltimoControllo = getdate(), 
                                                        eMailPec = @eMailPec,
                                                        descrizioneEsitoInipec = @descrizioneEsitoPec,
                                                        statoInipec = case when (@eMailPec is null or @eMailPec = '') 
                                                                            then 'NonPresente'
							                                          else
							                                                'Presente'
							                                          end
                                                     WHERE 
                                                        codiceFiscale = @codiceFiscale
                                                        and idHeader = @idDoc";
                                        cmd1 = new SqlCommand(strSQL, connection);
                                        cmd1.Parameters.AddWithValue("@idDoc", idDoc.ToString());
                                        cmd1.Parameters.AddWithValue("@descrizioneEsitoPec", row.DescrizioneEsitoPec);
                                        cmd1.Parameters.AddWithValue("@codiceFiscale", row.Input);
                                        cmd1.Parameters.AddWithValue("@eMailPec", row.PecImpresa);
                                        cmd1.ExecuteNonQuery();
                                    }
                                }
                            }
                        }

                        strCause = "Update sulla Services_Integration_Request per avanzare lo statoRichiesta a RicevutaRisposta";
                        strSQL = @"update Services_Integration_Request 
                                    set 
                                        statoRichiesta = @statoRichiesta, 
                                        DataExecuted = getDate(), 
                                        msgError = @errorMessage, 
                                        inputWS = @inputWS,
                                        outputWS = @outputWS
                                    where 
                                        idRow = @idRow";

                        cmd1 = new SqlCommand(strSQL, connection);
                        statoRichiesta = "RicevutaRisposta";
                        cmd1.Parameters.AddWithValue("@statoRichiesta", statoRichiesta);
                        cmd1.Parameters.AddWithValue("@errorMessage", xmlResponse.CodiceErrore);
                        cmd1.Parameters.AddWithValue("@inputWS", inputWS);
                        cmd1.Parameters.AddWithValue("@outputWS", soapResponseEnvelope + outputWS);
                        cmd1.Parameters.AddWithValue("@idRow", idRow);
                        cmd1.ExecuteNonQuery();
                    }

                    System.Web.HttpContext.Current.Response.Write("1#OK");
                }
                else /* se esito è false allora blocco le operazioni seguenti. In questo caso mi leggo i codici di errore */
                {
                    using (SqlConnection connection = new SqlConnection(connectionString))
                    {
                        connection.Open();
                        string stringError = string.Empty;

                        /* Recupero la stringa contente la descrizione dell'errore se presente */
                        strSQL = @"select ValOut 
                                        from CTL_Transcodifica 
                                        where sistema = 'INIPEC' 
                                        and dztNome = 'codiceErrore' 
                                        and ValIn = @CodiceErrore";
                        using (cmd1 = new SqlCommand(strSQL, connection))
                        {
                            cmd1.Parameters.AddWithValue("@CodiceErrore", xmlResponse.CodiceErrore);
                            rs = cmd1.ExecuteReader();

                            if (rs.Read())
                            {
                                stringError = (string)rs["ValOut"];
                                rs.Close();
                                throw new Exception($"Si è generato un errore lato WS INIPEC con codice di errore:{xmlResponse.CodiceErrore} - {stringError}");
                            }
                            else
                            {
                                rs.Close();
                                throw new Exception($"Si è generato un errore lato WS INIPEC con codice di errore:{xmlResponse.CodiceErrore}");
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                string errore = $"{MethodBase.GetCurrentMethod().Name} - {strCause} - {ex.Message}";

                /* scrivo nell'eventviewer */
                WriteToEventLog(errore);

                try
                {
                    rs.Close();
                }
                catch (Exception)
                {
                }

                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();
                    strSQL = @" update Services_Integration_Request 
                                    set 
                                        statoRichiesta = @statoRichiesta, 
                                        DataExecuted = getDate(), 
                                        msgError = @errorMessage, 
                                        inputWS = @inputWS, 
                                        outputWS = @outputWS 
                                    where
                                        idRow = @idRow";

                    statoRichiesta = "RicevutoErrore";
                    cmd1 = new SqlCommand(strSQL, connection);
                    cmd1.Parameters.AddWithValue("@statoRichiesta", statoRichiesta);
                    cmd1.Parameters.AddWithValue("@inputWS", inputWS);
                    cmd1.Parameters.AddWithValue("@outputWS", outputWS);
                    cmd1.Parameters.AddWithValue("@idRow", Convert.ToInt32(idRow));
                    if (xmlResponse.CodiceErrore != null)
                        cmd1.Parameters.AddWithValue("@errorMessage", $"{xmlResponse.CodiceErrore} - {errore}");
                    else
                        cmd1.Parameters.AddWithValue("@errorMessage", errore);
                    cmd1.ExecuteNonQuery();
                }

                //return BadRequest("0#KO");
                System.Web.HttpContext.Current.Response.Write("0#Errore");
            }
            finally
            {
                /* Alla fine delle operazioni elimino il file e lo zip PER NOME (se elimino tutto rischio di rompere il flusso di lavoro di un'altra chiamata al metodo)*/
                if (pathCsv != string.Empty && File.Exists(pathCsv))
                    File.Delete(pathCsv);

                if (pathZip != string.Empty && File.Exists(pathZip))
                    File.Delete(pathZip);
            }
        }


        public static void WriteToEventLog(string message)
        {
            try
            {
                string sSource = "AFLink";
                string sLog = "Application";
                string sMachine = "."; if (!EventLog.SourceExists(sSource, sMachine))
                    EventLog.CreateEventSource(sSource, sLog, sMachine);
                EventLog ELog = new EventLog(sLog, sMachine, sSource);
                ELog.WriteEntry(message, EventLogEntryType.Error);
            }
            catch (Exception)
            {
            }
        }
    }
}