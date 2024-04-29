using Chilkat;
using DocumentFormat.OpenXml.Bibliography;
using DocumentFormat.OpenXml.EMMA;
using DocumentFormat.OpenXml.Spreadsheet;
using DocumentFormat.OpenXml.Wordprocessing;
using eProcurementNext.CommonDB;
using eProcurementNext.Core.Storage;
using eProcurementNext.HTML;
using Microsoft.VisualBasic;
//using ServiceStack.Configuration;
using StackExchange.Redis;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Runtime.InteropServices;
using System.Text;
using System.Xml;
using System.Xml.Linq;
using System.Xml.Schema;
using static eProcurementNext.CommonDB.CommonDbFunctions;
using static eProcurementNext.CommonModule.Basic;
//using static ServiceStack.Diagnostics.Events;

namespace eProcurementNext.CommonModule
{
    public static class XmlUtil
    {

        static string xmlValidateError = string.Empty;
        static string xsd_lotti = string.Empty;

        public static bool Validate(string fileXml, string fileXsd)
        {
            bool esito = false;

            if (!string.IsNullOrEmpty(fileXml) && !string.IsNullOrEmpty(fileXsd))
            {
                if (!isXmlValid(fileXml, fileXsd))
                {

                }
            }

            return esito;
        }

        public static bool Import_XML(string idHeader, string fileXml, string connectionString)
        {
            bool esito = false;

            FileInfo fi = new FileInfo(fileXml);
            string basePath = fi.DirectoryName;

            if (!string.IsNullOrEmpty(idHeader) && !string.IsNullOrEmpty(fileXml))
            {
                if (CommonStorage.FileExists(fileXml))  // verificare se viene passato il path completo o meno
                {
                    xsd_lotti = getXsdPathFromXmlFile(fileXml); // recuperare l'xsd dal file xml
                    xsd_lotti = Path.Combine(basePath, xsd_lotti);

                    if (String.IsNullOrEmpty(importXml(fileXml, idHeader, xsd_lotti, connectionString)))
                    {
                        esito = true;
                    }
                    else
                    {
                        esito = false;
                    }
                }
            }

            return esito;
        }

        private static string importXml(string fileXml, string idHeader, string xsd_lotti, string connectionstring)
        {
            CommonDbFunctions cdf = new CommonDbFunctions();
            string result = string.Empty;

            XmlDocument m_xmld = new XmlDocument();
            XmlNodeList m_nodelist;
            //XmlNode nodoLotto;
            //XmlNode nodoGara;
            //XmlNode nodoPart;

            //Dim db As New Db()    '-- Connessione 1
            int contatore;
            string tagChiaveOE = string.Empty;
            string codFisc = string.Empty;
            string strCause = string.Empty;

            string strSql = string.Empty;

            long _idHeader = CLng(idHeader);

            Dictionary<string, object?> param = new Dictionary<string, object?>();

            SqlTransaction trans; 
            string connString = Application.ApplicationCommon.Application.ConnectionString;
            SqlConnection sconn = new SqlConnection(connString);


            param.Add("@xmlValidateError", xmlValidateError.Replace("'", "''"));
            param.Add("@idHeader", _idHeader);

            try
            {
                //'Caricamento dell'xml
                m_xmld = GetXmlDocumentSecure(fileXml, xsd_lotti, true);

                //'-- Validazione formale rispetto all'xsd specificato nel web.config
                if (!isXmlValid(fileXml, xsd_lotti))
                {


                    strSql = "update ctl_doc set note = @xmlValidateError where id = @idHeader";
                    cdf.Execute(strSql, connectionstring, parCollection: param);
                    result = xmlValidateError;
                }
            }
            catch (XmlException e)
            {
                param.Add("@message", e.Message);
                strSql = "update ctl_doc set note = @message where id = @idHeader";
                cdf.Execute(strSql, connectionstring, parCollection: param);

                result = "XML non valido";
            }


            sconn.Open();
            strCause = "begin transaction";

            trans = sconn.BeginTransaction();

            try
            {
                //sconn.Open();
                //strCause = "begin transaction";

                //trans = sconn.BeginTransaction();
                
                strCause = "cancello record precedenti";

                //'-- Cancello precedenti importazioni a parità di idheader

                param.Clear();

                param.Add("@idHeader", CLng(idHeader));

                strSql = "delete from document_AVCP_Import_CSV where idHeader = @idHeader";

                cdf.ExecuteWithTransaction(strSql, connectionstring, sconn, trans, parCollection: param);

                strCause = "recupero lista lotti";

                //-- Recupero tutti i lotti
                m_nodelist = m_xmld.SelectNodes("//data/lotto");

                //'-- Se sono presenti lotti
                if (m_nodelist != null && m_nodelist.Count > 0)
                {
                    strCause = "recupero query";
                    strSql = "INSERT INTO document_AVCP_Import_CSV([idheader], [Anno], [NumeroAutorita], [Cig], [CFprop], [Denominazione], [Scelta_contraente], [ImportoAggiudicazione], [DataInizio], [Datafine], [ImportoSommeLiquidate], [Oggetto], [DataPubblicazione], [Warning], [Gruppo], [Ruolopartecipante], [Estero], [Codicefiscale], [CodicefiscaleEstero], [Ragionesociale], [aggiudicatario]) VALUES(@idHeader, @Anno, NULL, @Cig, @CFprop, @Denominazione, @Scelta_contraente, @ImportoAggiudicazione, @DataInizio, @Datafine, @ImportoSommeLiquidate, @Oggetto, @DataPubblicazione, NULL, @Gruppo, @Ruolopartecipante, @Estero, @Codicefiscale, @CodicefiscaleEstero, @Ragionesociale, @aggiudicatario) ";

                    foreach (XmlNode nodoLotto in m_nodelist)
                    {
                        strCause = "init commando";
                        contatore = 0;

                        strCause = "setto i parametri sulla qquery";

                        param.Clear();

                        param.Add("@idHeader", CInt(idHeader));
                        param.Add("@Anno", null);
                        param.Add("@DataPubblicazione", null);

                        param.Add("@Cig", nodoLotto.SelectSingleNode("cig").InnerText);
                        param.Add("@Oggetto", nodoLotto.SelectSingleNode("oggetto").InnerText);
                        param.Add("@Scelta_contraente", Left(nodoLotto.SelectSingleNode("sceltaContraente").InnerText, 2));

                        strCause = "imposto variabili per l'internazionalizzazione";

                        NumberFormatInfo nfi = new CultureInfo("en-US", false).NumberFormat;
                        DateTimeFormatInfo dtfi = new CultureInfo("en-US", false).DateTimeFormat;

                        strCause = "settaggio importi";

                        Double importoAggiudicazione = default;
                        importoAggiudicazione = Double.Parse(nodoLotto.SelectSingleNode("importoAggiudicazione").InnerText, nfi);

                        Double importoSommeLiquidate = default;
                        importoSommeLiquidate = Double.Parse(nodoLotto.SelectSingleNode("importoSommeLiquidate").InnerText, nfi);

                        param.Add("@ImportoAggiudicazione", importoAggiudicazione);
                        param.Add("@ImportoSommeLiquidate", importoSommeLiquidate);

                        strCause = "settaggio date";
                        if (nodoLotto.SelectSingleNode("tempiCompletamento/dataInizio") != null)
                        {
                            DateTime dataInizio;

                            try
                            {
                                dataInizio = DateTime.Parse(nodoLotto.SelectSingleNode("tempiCompletamento/dataInizio").InnerText, dtfi);
                                if (IsDate(dataInizio))
                                {
                                    param.Add("@DataInizio", dataInizio);
                                }
                                else
                                {
                                    param.Add("@DataInizio", null);
                                }
                            }
                            catch
                            {
                                param.Add("@DataInizio", null);
                            }
                        }
                        else
                        {
                            param.Add("@DataInizio", null);
                        }

                        if (nodoLotto.SelectSingleNode("tempiCompletamento/dataUltimazione") != null)
                        {
                            DateTime dataFine;

                            try
                            {
                                string strTmp = nodoLotto.SelectSingleNode("tempiCompletamento/dataUltimazione").InnerText;
                                strTmp = Left(strTmp, 10);

                                if (IsDate(strTmp))
                                {
                                    dataFine = DateTime.Parse(strTmp, dtfi);
                                    param.Add("@DataFine", dataFine);
                                }
                                else
                                {
                                    param.Add("@DataFine", null);
                                }
                            }
                            catch
                            {
                                param.Add("@DataFine", null);
                            }
                        }
                        else
                        {
                            param.Add("@DataFine", null);
                        }

                        strCause = "settaggio parametri cf e denominazione";

                        param.Add("@CFprop", nodoLotto.SelectSingleNode("strutturaProponente/codiceFiscaleProp").InnerText);
                        param.Add("@Denominazione", Right(nodoLotto.SelectSingleNode("strutturaProponente/denominazione").InnerText, 300));

                        //'-- Se è presente un gruppo itero sui gruppi e aggiungo le info sul gruppo sulla riga corrente per poi passare alle righe successive, lasciando vuote le righe del lotto
                        //'-- e iterando sui membri del gruppo aggiungo una riga ogni volta per membro e metto solo le info del membro lasciando vuoto le info del lotto e del gruppo

                        if (nodoLotto.SelectNodes("partecipanti/raggruppamento").Count > 0)
                        {
                            //'-- Itero sui raggruppamenti
                            foreach (XmlNode nodoGara in nodoLotto.SelectNodes("partecipanti/raggruppamento"))
                            {
                                string denominazioneGruppo = string.Empty;

                                strCause = "recupero denominazione gruppo";

                                denominazioneGruppo = getDescGruppo(nodoLotto.SelectNodes("membro"));

                                //'-- itero sui membri del raggruppamento

                                foreach (XmlNode nodoPart in nodoGara.SelectNodes("membro"))
                                {
                                    //'-- se non è il primo mebro del primo gruppo
                                    if (contatore > 0)
                                    {
                                        strCause = "clear info lotto";

                                        //'-- Pulisco le info del lotto per mettere solo i nuovi dati del gruppo e del membro
                                        clearInfoLotto(param, idHeader);
                                    }

                                    strCause = "setto parametri lotto";

                                    //'-- le info sul gruppo vengono ripetute per gli N membri

                                    param.Add("@Gruppo", Right(denominazioneGruppo, 200));
                                    param.Add("@Ruolopartecipante", Right(nodoPart.SelectSingleNode("ruolo").InnerText, 200));

                                    //'-- se è presente il tag identificativoFiscaleEstero vuole dire che è estero

                                    if (nodoPart.SelectNodes("identificativoFiscaleEstero").Count > 0)
                                    {
                                        tagChiaveOE = "identificativoFiscaleEstero";
                                        codFisc = nodoPart.SelectSingleNode("identificativoFiscaleEstero").InnerText;

                                        param.Add("@Estero", "1");
                                        param.Add("@CodicefiscaleEstero", nodoPart.SelectSingleNode("identificativoFiscaleEstero").InnerText);
                                        param.Add("@CodiceFiscale", "");
                                    }
                                    else
                                    {
                                        tagChiaveOE = "codiceFiscale";
                                        codFisc = nodoPart.SelectSingleNode("codiceFiscale").InnerText;

                                        param.Add("@Estero", "0");
                                        param.Add("@CodicefiscaleEstero", "");
                                        param.Add("@CodiceFiscale", nodoPart.SelectSingleNode("codiceFiscale").InnerText);
                                    }

                                    param.Add("@Ragionesociale", Right(nodoPart.SelectSingleNode("ragioneSociale").InnerText, 80));

                                    //'-- Se trovo negli aggiudicatari il codice fiscale del partecipante su cui sto iterando vuol dire che è un
                                    //'-- aggiudicatario ( essendo il codice fiscale CHIAVE )

                                    strCause = "setto info aggiudicatario";

                                    if (nodoLotto.SelectNodes($"aggiudicatari/aggiudicatarioRaggruppamento/membro/{tagChiaveOE}[text() = '{codFisc}']").Count > 0) {
                                        param.Add("@aggiudicatario", "1");
                                    }
                                    else {
                                        param.Add("@aggiudicatario", "0");
                                    }

                                    strCause = "execute command";
                                    cdf.ExecuteWithTransaction(strSql, connString, sconn, trans, parCollection: param);  

                                    contatore += 1;
                                }
                            }
                        }

                        strCause = "itero sui partecipanti singoli";

                        //'-- Itero sui partecipanti singoli
                        foreach (XmlNode nodoPart in nodoLotto.SelectNodes("partecipanti/partecipante"))
                        {

                            // verificare qui se il contenuto di param è corretto o meno

                            //'-- se non è il primo partecipante
                            if (contatore != 0)
                            {
                                strCause = "clear info lotti singoli partecipanti";

                                //'-- Pulisco le info del lotto per mettere solo i nuovi dati del gruppo e del membro
                                clearInfoLotto(param, idHeader);
                            }

                            strCause = "set parametri singoli partecipanti";
                            param.Add("@Gruppo", string.Empty);
                            param.Add("@Ruolopartecipante", string.Empty);

                            strCause = "controllo estero su singoli partecipanti";

                            //'-- se è presente il tag identificativoFiscaleEstero vuole dire che è estero
                            if (nodoPart.SelectNodes("identificativoFiscaleEstero").Count > 0)
                            {
                                tagChiaveOE = "identificativoFiscaleEstero";
                                strCause = "Recupero identificativo fiscale esterno su singoli partecipanti";
                                codFisc = nodoPart.SelectSingleNode("identificativoFiscaleEstero").InnerText;
                                strCause = "set parametri per oe estero";

                                param.Add("@Estero", "1");
                                param.Add("@CodicefiscaleEstero", codFisc);
                                param.Add("@Codicefiscale", string.Empty);
                            }
                            else
                            {
                                tagChiaveOE = "codiceFiscale";

                                strCause = "Recupero codiceFiscale su singoli partecipanti";

                                codFisc = string.Empty;

                                if (nodoPart.SelectNodes("codiceFiscale").Count > 0) {
                                    codFisc = nodoPart.SelectSingleNode("codiceFiscale").InnerText;
                                }

                                strCause = "set parametri per oe italia";

                                param.Add("@Estero", "0");
                                param.Add("@CodicefiscaleEstero", string.Empty);
                                param.Add("@Codicefiscale", codFisc);
                            }

                            strCause = "set param ragioneSociale";
                            param.Add("@Ragionesociale", nodoPart.SelectSingleNode("ragioneSociale").InnerText);

                            //'-- Se trovo negli aggiudicatari il codice fiscale del partecipante su cui sto iterando vuol dire che è un
                            //'-- aggiudicatario ( essendo il codice fiscale CHIAVE )

                            if (nodoLotto.SelectNodes($"aggiudicatari/aggiudicatario/{tagChiaveOE}[text() = '{codFisc}']").Count > 0)
                            {
                                param.Add("@aggiudicatario", "1");
                            }
                            else
                            {
                                param.Add("@aggiudicatario", "0");
                            }

                            strCause = $"execute command per singoli partecipanti.CF: {codFisc}";

                            cdf.ExecuteWithTransaction(strSql, connString, sconn, trans, parCollection: param);

                            contatore += 1;
                        }

                        //'-- se non c'erano partecipanti singoli e gruppi resta il lotto deserto

                        if (nodoLotto.SelectNodes("partecipanti/partecipante").Count == 0 && nodoLotto.SelectNodes("partecipanti/raggruppamento/membro").Count == 0) { 

                            clearInfoPartecipante(param);
                            cdf.ExecuteWithTransaction(strSql, connString, sconn, trans, parCollection: param);
                            //db.initCommand()
                            contatore += 1;

                        }

                        // nodoLotto = null;  Perché?? verificare
                    }
                }

                strCause = "commit";
                trans.Commit();

                strCause = "esecuzione completata";

                cdf.Execute($"update ctl_doc set note = '' where id = {CLng(idHeader)}",connString, sconn);  // gestire con parametri dopo test di verifica

                result = "";

            }
            catch (Exception ex)
            {
                result = $"Errore: {ex.Message}  -  {strCause}";
                trans.Rollback();

                cdf.Execute($"update ctl_doc set note = '{Replace(ex.Message, "'", "''")}' where id = {CLng(idHeader)}", connString, sconn);
            }
            finally
            {
                if(sconn.State != ConnectionState.Closed)
                {
                    sconn.Close();
                }
                
            }
            return result;
        }

        private static string getDescGruppo(XmlNodeList listaNodi)
        {

            string ret = string.Empty;

            foreach (XmlNode membro in listaNodi)
            {
                ret += $"{membro.SelectSingleNode("ragioneSociale").InnerText} ";
            }

            return Left(ret, ret.Length - 1);


        }

        private static void clearInfoPartecipante(Dictionary<string, object?> param)
        {
            // verificare contenuto param
            if (param.ContainsKey("@Gruppo")) param["@Gruppo"] = string.Empty;
            if (param.ContainsKey("@Ruolopartecipante")) param["@Ruolopartecipante"] = string.Empty;

            if (param.ContainsKey("@Estero")) param["@Estero"] = string.Empty;
            if (param.ContainsKey("@CodicefiscaleEstero")) param["@CodicefiscaleEstero"] = string.Empty;
            if (param.ContainsKey("@Codicefiscale")) param["@Codicefiscale"] = string.Empty;

            if (param.ContainsKey("@Ragionesociale")) param["@Ragionesociale"] = string.Empty;
            if (param.ContainsKey("@aggiudicatario")) param["@aggiudicatario"] = string.Empty;
        }

        private static void clearInfoLotto(Dictionary<string, object?> param, string idHeader)
        {

            // verificare contenuto param
           if(param.ContainsKey("@idHeader"))
            {
                param["@idHeader"] = idHeader;
            }

            if (param.ContainsKey("@Anno")) param["@Anno"] = DBNull.Value;
            if (param.ContainsKey("@DataPubblicazione")) param["@DataPubblicazione"] = DBNull.Value;

            if (param.ContainsKey("@Cig")) param["@Cig"] = string.Empty;
            if (param.ContainsKey("@Oggetto")) param["@Oggetto"] = string.Empty;
            if (param.ContainsKey("@Scelta_contraente")) param["@Scelta_contraente"] = string.Empty;

            if (param.ContainsKey("@ImportoAggiudicazione")) param["@ImportoAggiudicazione"] = DBNull.Value;
            if (param.ContainsKey("@ImportoSommeLiquidate")) param["@ImportoSommeLiquidate"] = DBNull.Value;

            if (param.ContainsKey("@DataInizio")) param["@DataInizio"] = DBNull.Value;
            if (param.ContainsKey("@DataFine")) param["@DataFine"] = DBNull.Value;

            if (param.ContainsKey("@CFprop")) param["@CFprop"] = string.Empty;
            if (param.ContainsKey("@Denominazione")) param["@Denominazione"] = string.Empty;

        }

        private static bool isXmlValid(string fileXml, string fileXsd)
        {
            bool esito = false;
            XmlDocument myDocument = new XmlDocument();
            try
            {
                myDocument = GetXmlDocumentSecure(fileXml, fileXsd, true);
                ValidationEventHandler eventHandler = new ValidationEventHandler(ValidationCallBack);

                myDocument.Validate(eventHandler);
                xmlValidateError = string.Empty;
                esito = true;
            }
            catch (Exception ex)
            {
                esito = false;
                xmlValidateError = $"Errore server nella validazione: {ex.Message}";
            }

            return esito;

        }



        private static void ValidationCallBack(object sender, ValidationEventArgs args)
        {

            switch (args.Severity)
            {
                case XmlSeverityType.Error:
                    xmlValidateError += args.Message;
                    break;
                case XmlSeverityType.Warning:
                    // gestione errore?
                    break;
            }

        }

        public static XmlSchema LoadSchema(string pathname)
        {
            XmlSchema s = null;

            XmlReaderSettings settings = new XmlReaderSettings();
            // per impedire il DTD Processing e l'XML Bombs
            settings.ProhibitDtd = false;
            settings.MaxCharactersFromEntities = 1024;

            System.IO.Stream fs = new FileStream(pathname, FileMode.Open);

            try
            {
                using (XmlReader r = XmlReader.Create(fs, settings))
                {
                    s = XmlSchema.Read(r, new ValidationEventHandler(ValidationCallBack));
                }
            }
            catch (Exception ex)
            {
                string boh = ex.Message;
            }
            finally
            {
                fs.Close();
            }

            return s;
        }


        public static nestedXsdRef LoadSchemaAndResolveIncludes(string pathname)
        {
            FileInfo f = new FileInfo(pathname);
            XmlSchema s = LoadSchema(f.FullName);

            var schemaSet = new XmlSchemaSet();
            var include = new XmlSchemaInclude();

            nestedXsdRef nsx = new nestedXsdRef();
            nsx.TargetNameSpace = s.TargetNamespace;
            List<string> locs = new List<string>();

            locs.Add(pathname);

            foreach (XmlSchemaInclude i in s.Includes)
            {
                XmlSchema si = LoadSchema(f.Directory.FullName + @"\" + i.SchemaLocation);
                locs.Add(f.Directory.FullName + @"\" + i.SchemaLocation);
            }

            nsx.schemaLocationList = locs;

            return nsx;
        }




        private static XmlDocument GetXmlDocumentSecure(string xmlDoc, string xsdDoc, bool isFile = false)
        {


            //-- NON USIAMO PIU' L'XMLDOCUMENT DIRETTAMENTE MA PASSIAMO DA UN XmlReader configurato con ProhibitDtd = false per Disabilitare le entity esterne e il "DTD Processing". attacchi XXE
            XmlDocument m_xmld = new XmlDocument();


            XmlReader reader;

            System.IO.Stream stream;
            //string[] xsdPath = LoadSchemaIncludes(xmlDoc);

            if (isFile)
            {
                //'-- Carico il documento da un file invece che dallo stringone xml
                m_xmld.Load(xmlDoc);
                stream = new FileStream(CStr(xmlDoc), FileMode.Open, System.IO.FileAccess.Read);
            }
            else
            {
                stream = new MemoryStream(System.Text.Encoding.Default.GetBytes(xmlDoc));
            }

            XmlReaderSettings settings = new XmlReaderSettings();
            // per impedire il DTD Processing e l'XML Bombs
            settings.ProhibitDtd = false;
            settings.MaxCharactersFromEntities = 1024;
            //settings.XmlResolver = new XmlUrlResolver();
            settings.ValidationType = ValidationType.Schema;

            reader = XmlReader.Create(stream, settings);

            m_xmld.XmlResolver = null; // per impedire le entity esterne
            m_xmld.Load(reader);

            nestedXsdRef nestedXsdRef = LoadSchemaAndResolveIncludes(xsdDoc);

            XmlSchemaSet xss = new XmlSchemaSet();

            foreach (string loc in nestedXsdRef.schemaLocationList)
            {
                settings.Schemas.Add(nestedXsdRef.TargetNameSpace, loc);
            }


            stream.Close();
            stream.Dispose();

            return m_xmld;
        }

        private static XmlDocument GetXmlDocumentSecure(string xmlDoc, bool isFile = false)
        {


            //-- NON USIAMO PIU' L'XMLDOCUMENT DIRETTAMENTE MA PASSIAMO DA UN XmlReader configurato con ProhibitDtd = false per Disabilitare le entity esterne e il "DTD Processing". attacchi XXE
            XmlDocument m_xmld = new XmlDocument();


            XmlReader reader;
            XmlReader readerForIncludedXsd;

            System.IO.Stream stream;
            //string[] xsdPath = LoadSchemaIncludes(xmlDoc);

            if (isFile)
            {
                //'-- Carico il documento da un file invece che dallo stringone xml
                m_xmld.Load(xmlDoc);
                stream = new FileStream(CStr(xmlDoc), FileMode.Open, System.IO.FileAccess.Read);
            }
            else
            {
                stream = new MemoryStream(System.Text.Encoding.Default.GetBytes(xmlDoc));
            }

            XmlReaderSettings settings = new XmlReaderSettings();
            // per impedire il DTD Processing e l'XML Bombs
            settings.ProhibitDtd = false;
            settings.MaxCharactersFromEntities = 1024;
            settings.XmlResolver = null;

            reader = XmlReader.Create(stream, settings);

            m_xmld.XmlResolver = null; // per impedire le entity esterne
            m_xmld.Load(reader);

            stream.Close();
            stream.Dispose();

            return m_xmld;
        }

        public static string getXsdPathFromXmlFile(string fileXml)
        {
            XmlTextReader reader = new XmlTextReader(fileXml);
            XmlDocument doc = new XmlDocument();
            doc.Load(reader);
            reader.Close();
            XmlElement root = doc.DocumentElement;
            string xsdRef = string.Empty;
            string[] components = new string[0];

            XmlNode schemaLocationAttribute = root.SelectSingleNode("//@*[local-name()='schemaLocation']");

            if (schemaLocationAttribute != null)
            {
                components = schemaLocationAttribute.Value.Split(null);
                xsdRef = components[1];
            }

            return xsdRef;
        }

        public static string XmlEncode(string str)
        {
            string? s;
            string caratteriAmmessi;
            int i;

            //On Error Resume Next

            caratteriAmmessi = @"QWERTYUIOPASDFGHJKLZXCVBNMòàùè%$£€~@ +1234567890'ì:\/!$%()=^{[]}_-?&;.,*+#";
            //'caratteriAmmessi = ""

            s = Strings.Replace(str, @"&", @"&amp;");
            s = Strings.Replace(s, @"<", @"&lt;");
            s = Strings.Replace(s, @">", @"&gt;");
            s = Strings.Replace(s, @"""", @"&quot;");
            s = Strings.Replace(s, @"'", @"&apos;");


            string tmp = "";
            string c = "";
            int l;

            l = s != null ? Len(s) : 0;
            //'tmp = CStr(s)

            for (i = 1; i <= l; i++)
            {// To l

                c = Strings.Mid(s, i, 1);

                if (Strings.AscW(c) < 10)
                {
                    c = " ";
                }

                if (Strings.InStr(1, Strings.UCase(caratteriAmmessi), Strings.UCase(c)) > 0)
                {
                    //c = c;
                }
                else
                {
                    //'c = "&#x" & Right("0000" & Hex(AscW(c)), 4) & ";"
                    c = "&#" + Strings.AscW(c) + ";";
                }


                tmp = tmp + c;

            }


            return tmp;

            //err.Clear
        }

        public static void openXmlDocument(string typeDoc, string lingua, IEprocResponse response, bool isDoc = true)
        {

            if (lingua == "")
            {
                lingua = "I";
            }

            response.Write(@"<?xml version=""1.0"" encoding=""UTF-8""?>" + Environment.NewLine);

            response.Write("<" + UCase(typeDoc) + @" language=""" + lingua + @""">" + Environment.NewLine);

            if (isDoc)
            {
                response.Write("<SECTIONS>" + Environment.NewLine);
            }
        }

        public static void closeXmlDocument(string typeDoc, IEprocResponse response, bool isDoc = true)
        {
            if (isDoc)
            {
                response.Write("</SECTIONS>" + Environment.NewLine);
            }
            response.Write("</" + UCase(typeDoc) + ">" + Environment.NewLine);
        }

        public static void addXmlSection(string id, string typeSec, IEprocResponse response)
        {
            response.Write("<" + UCase(id) + @" type=""" + UCase(typeSec) + @""">" + Environment.NewLine);
        }

        public static void closeXmlSection(string id, IEprocResponse response)
        {
            response.Write("</" + UCase(id) + ">" + Environment.NewLine);
        }


        //public static void addXmlField(Field fld, IEprocResponse response, string attributes = "")
        //{
        //    string caption = fld.Caption;
        //    if (!String.IsNullOrEmpty(caption)) caption = XmlEncode(caption);

        //    response.Write("<" + UCase(fld.Name) + @" desc=""" + caption + @""" type=""" + getFieldTypeDesc(fld.getType()) + @"""" + attributes + @" visualdesc=""");
        //    fld.xml(response, "value");
        //    response.Write(@""">");
        //}

        public static void closeXmlField(string name, IEprocResponse response)
        {
            response.Write("</" + UCase(name) + ">" + Environment.NewLine);
        }


        //public static void addXmlFieldValue(IEprocResponse response, Field fld)
        //{
        //    fld.xml(response, "techvalue");
        //}

        public static string getFieldTypeDesc(int fieldType)
        {
            switch (fieldType)
            {
                case 1: //'-- text
                    return "Text";
                case 2: //'-- 2 = numerico
                    return "Number";
                case 3: //'-- textArea
                    return "TextArea";
                case 4: //'-- dominio chiuso
                    return "Domain";
                case 5: //'-- gerarchico
                    return "Hiearchy";
                case 6:
                    return "Date";
                case 7:
                    return "NumberColor";
                case 8: //'-- dominio esteso
                    return "ExtendedDomain";
                case 9: //'-- checkbox
                    return "CheckBox";
                case 10: //'-- Radio button
                    return "RadioButton";
                case 11: //'-- LABEL
                    return "Label";
                case 12: //'-- Foto
                    return "Photo";
                case 13: //'-- URL
                    return "Url";
                case 14: //'-- mail
                    return "Mail";
                case 15: //'-- STATIC ( a differenza delle label questo si usa solo per la caption senza un valore associato )
                    return "Static";
                case 16: //'-- HR ( è usato per i modelli verticali per introdurre line orizzontali
                    return "HR";
                case 18: //'-- attributo attach
                    return "Attach";
                case 19: //'-- Logo azienda
                    return "Logo";
                case 20: //'-- Publicità legale
                    return "PubLeg";
                case 21: //'-- Descrizione dal DB
                    return "DescDB";
                case 22:
                    return "Date";
                default:
                    return "GenericField";
            }
        }
    }

    public class nestedXsdRef
    {
        public string TargetNameSpace { get; set; }
        public List<string> schemaLocationList { get; set; }
    }
}
