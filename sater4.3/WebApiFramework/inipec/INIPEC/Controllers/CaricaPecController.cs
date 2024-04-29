using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Net;
using System.Text;
using System.Web.Http;
using System.IO.Compression;
using System.Reflection;
using System.Xml;
using System.Security.Authentication;
using System.Data.SqlClient;
using System.Web.Services.Description;
using System.Diagnostics;

namespace INIPEC_WS.Controllers
{
    public class XMLCaricaPecresponse
    {
        public string IdRichiesta { get; set; }
        public string Esito { get; set; }
        public string TipoRichiesta { get; set; }
        public string CodiceErrore { get; set; }
    }
    public class CaricaPecController : ApiController
    {
        public const SslProtocols _Tls12 = (SslProtocols)0x00000C00;
        public const SecurityProtocolType Tls12 = (SecurityProtocolType)_Tls12;

        public void TemplateIntegrationRequest()
        {
            ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };
        }

        [HttpGet]
        public void CaricaDatiPec(string ID, string OPERATION)
        {
            /* Inzializzo variabili */
            string strCause = string.Empty;
            string txtName = string.Empty;
            string zipName = string.Empty;
            string pathMain = string.Empty;
            string operazioneRichiesta = string.Empty;
            string response = string.Empty;
            int retry = 6;
            int idDoc;
            string XMLbody = string.Empty;
            string inputWS = string.Empty;
            string pathFull = string.Empty;
            string outputWS = string.Empty;
            string strSQL = string.Empty;
            int testIDnumber = 0;
            string statoRichiesta = string.Empty;
            string sysPath = "SYS_PathFolderAllegati";
            string idRow = string.Empty;
            string basicUsername = string.Empty;
            string basicPassword = string.Empty;
            string connectionString = ConfigurationManager.AppSettings["db.conn"];


            /* Istanzio oggetti */
            XMLCaricaPecresponse xmlResponse = new XMLCaricaPecresponse();
            SqlConnection sqlConn = null;
            SqlDataReader rs = null;
            SqlCommand cmd1 = new SqlCommand();

            /* Eseguo controlli sui dati forniti in input alla chiamata */
            if (ID == "")
                throw new Exception("Parametro ID obbligatorio");

            bool testID = Int32.TryParse(ID, out testIDnumber);

            if (!testID)
            {
                throw new Exception("Parametro ID non valido");
            }

            /* Assegno il valore dopo aver controllato che sia corretto formalmente */
            idRow = ID;

            try
            {
                /* Recupero parametri da Configuration Manager */
                strCause = "Recupero i parametri dal Configuration Manager";
                string nomeDocumento = ConfigurationManager.AppSettings["InfoCamere.CaricaPec.NomeDocumento"];
                string tipoDocumento = ConfigurationManager.AppSettings["InfoCamere.TipoDocumento"];
                string indirizzoWS = ConfigurationManager.AppSettings["InfoCamere.Indirizzo_WS"];
                string indirizzoClient = ConfigurationManager.AppSettings["InfoCamere.Client"];
                string soapAction = ConfigurationManager.AppSettings["InfoCamere.SOAPAction.CaricaPec"];
                string endPoint = ConfigurationManager.AppSettings["InfoCamere.Endpoint"];
                string partialPath = ConfigurationManager.AppSettings["InfoCamere.CaricaPec.FilePath"];

                /*Leggo valore path file tmp da SYS */
                strCause = "Ottengo valore della directory dove andare a scrivere i file temporanei";
                strSQL = @" select 
                                DZT_VALUEDEF 
                            FROM LIB_DICTIONARY WITH(NOLOCK) 
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


                    /* Avanzo lo statoRichiesta a "InGestione" */
                    strCause = "Faccio avanzare lo statoRichiesta della Services_Integration_Request ad 'InGestione'";
                    strSQL = @" UPDATE Services_Integration_Request 
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
                                from Services_Integration_Request a with(nolock) 
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
                    connection.Close();
                }

                /* Inizializzo le impostazioni di sicurezza del protocolloI */
                strCause = "Inizializzo le impostazioni di sicurezza del protocollo";
                ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };
                ServicePointManager.Expect100Continue = true;
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | (SecurityProtocolType)192 | (SecurityProtocolType)768 | (SecurityProtocolType)3072;


                /* Compongo le variabili */
                nomeDocumento = $"{nomeDocumento}_{DateTime.Now:yyyy_MM_dd_HH_mm_ss_fff}";
                zipName = $"{nomeDocumento}.{tipoDocumento}";
                txtName = $"{nomeDocumento}.txt";
                pathFull = Path.Combine(pathMain, partialPath);

                /* Compongo la lista aggiornata dei CF/CA */
                ComponiListaInvio(pathFull, zipName, txtName, idDoc, connectionString);

                /* Converto in base64 il file */
                byte[] zipByte = File.ReadAllBytes(pathFull + zipName);
                string base64zip = Convert.ToBase64String(zipByte);

                /* Compongo il body della request */
                strCause = "Compongo il body della request";
                XMLbody =
                @"<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/envelope/"" xmlns:ws=""{Indirizzo_WS}"">
                    <soapenv:Header/>
                    <soapenv:Body>
                        <ws:richiestaRichiestaFornituraPec>
                            <elencoCf>
                                <nomeDocumento>{NomeDocumento}</nomeDocumento>
                                <tipoDocumento>{TipoDocumento}</tipoDocumento>
                                <documento>{fileContent}</documento>
                            </elencoCf>
                        </ws:richiestaRichiestaFornituraPec>
                    </soapenv:Body>
                  </soapenv:Envelope>";

                /* Sosituisco i placeholder nel body con i valori parametrizzati dal configuration manager */
                strCause = "Eseguo il replace dei placeholder nel corpo XML";
                XMLbody = XMLbody.Replace("{Indirizzo_WS}", indirizzoWS);
                XMLbody = XMLbody.Replace("{NomeDocumento}", "dati");
                XMLbody = XMLbody.Replace("{TipoDocumento}", tipoDocumento);
                XMLbody = XMLbody.Replace("{fileContent}", base64zip);

                string encodedAuth = System.Convert.ToBase64String(Encoding.GetEncoding("ISO-8859-1")
                                        .GetBytes(basicUsername + ":" + basicPassword));

                response = InvokeSoapMultiPart(indirizzoClient + endPoint, soapAction, XMLbody, encodedAuth);

                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.LoadXml(response);

                /* Risolvo i namespace del documento */
                var soapNamespace = new XmlNamespaceManager(xmlDoc.NameTable);
                soapNamespace.AddNamespace("soap", ConfigurationManager.AppSettings["InfoCamere.XMLnamespace.soap"]);
                soapNamespace.AddNamespace("ns3", ConfigurationManager.AppSettings["InfoCamere.XMLnamespace.ns3"]);

                /* Creo due nodelist con il percorso dei dati necessari */
                strCause = "Creo le nodelist dell'xml response e assegno i valori alle proprietà di un oggetto";
                XmlNodeList xnListEsito = xmlDoc.SelectNodes("/soap:Envelope/soap:Body/ns3:rispostaRichiestaFornituraPec/esito", soapNamespace);
                XmlNodeList xnListFornitura = xmlDoc.SelectNodes("/soap:Envelope/soap:Body/ns3:rispostaRichiestaFornituraPec/identificativiFornitura/tokenRichiestaInfocamere", soapNamespace);

                /* Scalando le due nodelist appena generate ottengo i valori necessari per le lavorazioni */
                foreach (XmlNode xn in xnListEsito)
                {
                    xmlResponse.Esito = xn["esito"].InnerText;
                    xmlResponse.CodiceErrore = xn["codiceErrore"].InnerText;
                }

                foreach (XmlNode xn in xnListFornitura)
                {
                    xmlResponse.TipoRichiesta = xn["tipoRichiesta"].InnerText;
                    xmlResponse.IdRichiesta = xn["idRichiesta"].InnerText;
                }

                if (xmlResponse.Esito == "true")
                {
                    using (SqlConnection connection = new SqlConnection(connectionString))
                    {
                        connection.Open();
                        strSQL = @" update Services_Integration_Request
                                    set 
                                        statoRichiesta = @statoRichiesta, 
                                        datoRichiesto = @datoRichiesto,
                                        DataExecuted = getDate(), 
                                        msgError = @errorMessage, 
                                        inputWS = @inputWS, 
                                        outputWS = @outputWS 
                                    where 
                                        idRow = @idRow";

                        using (cmd1 = new SqlCommand(strSQL, connection))
                        {
                            /* La chiamata è andata a buon fine e mi salvo nella colonna datoRichiesto l'idRichiesta da processare nel WS successivo */
                            strCause = "Update sulla Services_Integration_Request per avanzare lo statoRichiesta a RicevutaRisposta";
                            statoRichiesta = "RicevutaRisposta";
                            cmd1.Parameters.AddWithValue("@statoRichiesta", statoRichiesta);
                            cmd1.Parameters.AddWithValue("@datoRichiesto", xmlResponse.IdRichiesta);
                            cmd1.Parameters.AddWithValue("@errorMessage", xmlResponse.CodiceErrore);
                            cmd1.Parameters.AddWithValue("@inputWS", XMLbody);
                            cmd1.Parameters.AddWithValue("@outputWS", response);
                            cmd1.Parameters.AddWithValue("@idRow", idRow);
                            cmd1.ExecuteNonQuery();
                        }
                        connection.Close();
                    }
                    //return Ok("1#OK");
                    System.Web.HttpContext.Current.Response.Write("1#OK");
                }
                else
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

                    using (cmd1 = new SqlCommand(strSQL, connection))
                    {
                        statoRichiesta = "RicevutoErrore";
                        cmd1.Parameters.AddWithValue("@statoRichiesta", statoRichiesta);
                        cmd1.Parameters.AddWithValue("@inputWS", XMLbody);
                        cmd1.Parameters.AddWithValue("@outputWS", response);
                        cmd1.Parameters.AddWithValue("@idRow", idRow);
                        if (xmlResponse.CodiceErrore != null)
                            cmd1.Parameters.AddWithValue("@errorMessage", $"{xmlResponse.CodiceErrore} - {errore}");
                        else
                            cmd1.Parameters.AddWithValue("@errorMessage", errore);

                        cmd1.ExecuteNonQuery();
                    }

                    System.Web.HttpContext.Current.Response.Write("0#Errore");
                }
            }
            finally
            {
                /* Alla fine delle operazioni elimino il file e lo zip PER NOME (se elimino tutto rischio di rompere il flusso di lavoro di un'altra chiamata al metodo)*/
                if (txtName != string.Empty && File.Exists($"{pathFull}{zipName}"))
                    File.Delete($"{pathFull}{zipName}");

                if (zipName != string.Empty && File.Exists($"{pathFull}{txtName}"))
                    File.Delete($"{pathFull}{txtName}");

                try
                {
                    sqlConn.Close();
                }
                catch (Exception ex)
                {

                }

            }
        }

        public string InvokeSoapMultiPart(string url, string soapAction, string soapEnvelope, string encodedAuth)
        {
            string outS = "";
            string strCause = string.Empty;
            HttpWebRequest wr = null;
            WebResponse wresp = null;

            try
            {
                strCause = "Compongo il request boundary";
                string boundary = "---------------------------" + DateTime.Now.Ticks.ToString("x");
                byte[] boundarybytes = System.Text.Encoding.ASCII.GetBytes(Environment.NewLine + "--" + boundary + Environment.NewLine);

                strCause = "genero l'obj HttpWebRequest per l'url : '" + url + "'";
                wr = (HttpWebRequest)WebRequest.Create(new Uri(url));

                string strPayLoadHeaderMetaFileName = string.Empty;

                UTF8Encoding enc = new System.Text.UTF8Encoding();

                ServicePointManager.Expect100Continue = false;

                wr.ContentType = @"multipart/related; type=""application/xop+xml""; start=""<info@teamsystem.com>""; boundary=" + boundary;

                wr.Headers.Add("SOAPAction", soapAction);
                wr.Headers.Add("Accept-Encoding", "gzip,deflate");
                wr.Headers.Add("Authorization", $"Basic {encodedAuth}");

                wr.Method = "POST";
                wr.KeepAlive = true;

                string headerTemplate = "Content-Type: text/xml; charset=UTF-8" + Environment.NewLine;
                headerTemplate = headerTemplate + "Content-Transfer-Encoding: 8bit" + Environment.NewLine;
                headerTemplate = headerTemplate + "Content-ID: <info@teamsystem.com>" + Environment.NewLine + Environment.NewLine;

                byte[] BytesMetaFile = null;

                BytesMetaFile = System.Text.Encoding.UTF8.GetBytes(soapEnvelope);

                byte[] headerbytes2 = System.Text.Encoding.UTF8.GetBytes(headerTemplate);

                strCause = "compongo il request trailer";

                byte[] trailer = System.Text.Encoding.ASCII.GetBytes(Environment.NewLine + "--" + boundary + "--" + Environment.NewLine);

                Stream rs = wr.GetRequestStream();

                strCause = "Inizio a scrivere lo stream della busta soap in request";
                rs.Write(boundarybytes, 0, boundarybytes.Length);
                rs.Write(headerbytes2, 0, headerbytes2.Length);
                rs.Write(BytesMetaFile, 0, BytesMetaFile.Length);


                /* chiudo lo stream con il trailer */
                strCause = "scrivo lo stream del trailer";
                rs.Write(trailer, 0, trailer.Length);
                rs.Close();

                strCause = "Recupero la response";
                wresp = wr.GetResponse();

                Stream stream2 = wresp.GetResponseStream();
                StreamReader reader2 = new StreamReader(stream2);

                outS = reader2.ReadToEnd();


                /* Isolo il body XML dal resto della response */
                string mrkInzioXML = "<soap:Envelope";
                string mrkFineXML = "</soap:Envelope";
                int inizoXML = outS.IndexOf(mrkInzioXML);
                int lengthXML = (outS.IndexOf(mrkFineXML) - outS.IndexOf(mrkInzioXML) + mrkFineXML.Length + 1);

                string Output = outS.Substring(inizoXML, lengthXML);

                return Output;

            }
            catch (Exception ex)
            {

                if (wresp != null)
                {
                    wresp.Close();
                }

                throw new Exception($"Errore nella chiamata soapWithAttachment - {strCause} - {ex.Message}", ex);
            }
        }

        private void ComponiListaInvio(string pathMain, string zipName, string txtName, int idDoc, string connectionString)
        {
            string listaCompleta = "";
            string strCause = string.Empty;

            /* Dal DB ottengo la lista aggiornata dei Clienti ed estraggo i Codici Azienda/Fiscali su file di testo */
            strCause = "Ottengo dalla tabella Document_INIPEC la lista di Codici Fiscali da lavorare";
            List<string> CodiciAzienda = new List<string>();
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();
                string query = @"select 
                                    codiceFiscale 
                                 from Document_INIPEC 
                                 where 
                                    idHeader = @idHeader 
                                    and statoInipec = 'DaControllare'";
                using (SqlCommand command = new SqlCommand(query, connection))
                {
                    command.Parameters.AddWithValue("@idHeader", idDoc);
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            CodiciAzienda.Add(reader.GetString(0));
                        }
                    }
                }

                /* Compongo un'unica stringa con gli elementi in lista concatenati */
                if (CodiciAzienda.Count == 0)
                {
                    throw new Exception($"La lista di CodiciAzienda ottenuta per eseguire la chiamata risulta essere vuota.");
                }
                else
                {
                    foreach (var codice in CodiciAzienda)
                        listaCompleta += codice + Environment.NewLine;
                }

                /* Eseguo update su stato */
                query = @"UPDATE Document_INIPEC 
                            SET 
                                statoInipec = 'ControlloInCorso' 
                            where 
                                idHeader = @idHeader 
                                and statoInipec = 'DaControllare'";
                using (SqlCommand command = new SqlCommand(query, connection))
                {
                    command.Parameters.AddWithValue("@idHeader", idDoc);
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            CodiciAzienda.Add(reader.GetString(0));
                        }
                    }
                }
            }

            /* Tolgo dalla coda della stringa l'ultimo carattere non necessario*/
            if (listaCompleta.Length != 0) //controllo di ulteriore sicurezza su stringa vuota (anche se non dovrebbe essere possibile)
                listaCompleta = listaCompleta.Remove(listaCompleta.Length - 2);

            /* Controllo se la cartella di destinazione esiste e cancello evenutali omonimi di file // arichivo */
            strCause = "Creo la cartella di testo per lavorare i file (se non già presente) e elimino eventuali omonimi già presenti al suo interno.";
            if (!Directory.Exists(pathMain))
                Directory.CreateDirectory(pathMain);

            if (File.Exists($"{pathMain}{txtName}"))
                File.Delete($"{pathMain}{txtName}");

            if (File.Exists($"{pathMain}{zipName}"))
                File.Delete($"{pathMain}{zipName}");


            /* Scrivo il file txt */
            File.WriteAllText($"{pathMain}{txtName}", listaCompleta);

            using (var fileStream = new FileStream($"{pathMain}{zipName}", FileMode.CreateNew))
            {
                using (var archive = new ZipArchive(fileStream, ZipArchiveMode.Create, true))
                {

                    var txtBytes = File.ReadAllBytes($"{pathMain}{txtName}");
                    var zipArchiveEntry = archive.CreateEntry($"{txtName}", CompressionLevel.Fastest);
                    using (var zipStream = zipArchiveEntry.Open())
                    {
                        zipStream.Write(txtBytes, 0, txtBytes.Length);
                        zipStream.Close();
                    }
                }
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


/* SIGNIFICATO CODICI DI ERRORE -- DA LAVORARE POST RESPONSE  */
//switch (xmlResponse.CodiceErrore)
//{
//    case "OK":
//        //Esito positivo
//        break;
//    case "EF1":
//        strCause = "EF1 - Si e' verificato un errore nell'elaborazione della richiesta";
//        break;
//    case "EF2":
//        strCause = "EF2 - Si e' verificato un errore nell'elaborazione del file allegato";
//        break;
//    case "EF3":
//        strCause = "EF3 - Impossibile elaborare la richiesta: tipoDocumento deve essere ZIP";
//        break;
//    case "EF4":
//        strCause = "EF4 - Si e' verificato un errore nel recupero del file fornitura";
//        break;
//    case "EF5":
//        strCause = "EF5 - Tipo richiesta non valida";
//        break;
//    case "EF6":
//        strCause = "EF6 - Si e' verificato un errore nell'elaborazione della richiesta";
//        break;
//    case "EB1":
//        strCause = "EB1 - Si e' verificato un errore nell'elaborazione della richiesta";
//        break;
//    case "EB2":
//        strCause = "EB2 - Username o filename non specificati";
//        break;
//    case "EB3":
//        strCause = "EB3 - Si e' verificato un errore nell'elaborazione della richiesta";
//        break;
//    case "EB4":
//        strCause = "EB4 - Username, tipo richiesta o identificativo richiesta non specificati";
//        break;
//    case "EB5":
//        strCause = "EB5 - Richiesta non trovata con gli identificativi forniti";
//        break;
//    case "EB6":
//        strCause = "EB6 - La ricerca effettuata ha prodotto più di un risultato tra le richieste";
//        break;
//}