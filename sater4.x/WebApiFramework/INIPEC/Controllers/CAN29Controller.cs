using INIPEC.Library;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Web;
using System.Web.Http;
using static System.Net.Mime.MediaTypeNames;

namespace INIPEC.Controllers
{
    public class CAN29Controller : ApiController
    {
        private static readonly string BasePath = AppDomain.CurrentDomain.BaseDirectory;
        private readonly EformUtils _utils = new EformUtils();

        private static string GetCurrentPath()
        {
            return BasePath;
        }

        /// <summary>
        /// Funzione di innesco per la generazione dell'eForm CAN-29 ( aggiudicazione ). Invocabile sia da codice che come api rest
        /// </summary>
        /// <param name="id">Parametro obbligatorio. è l'id della PDA se operation monolotto. è l'id della microlotti dettagli se operation singolo_lotto o ''. è l'id della gara se operation deserta</param>
        /// <param name="idpfu">Parametro opzionale. è l'idpfu dell'utente in sessione, -20 di default</param>
        /// <param name="lotto">parametro opzionale. vuoto per tutti i lotti oppure una lista separata da virgola con i numeri lotto richiesti ( o un solo numero lotto )</param>
        /// <param name="operation">parametro opzionale. operazione richiesta : stringa vuota, monolotto, singolo_lotto, deserta</param>
        /// <param name="idContrattoConv">parametro opzionale. è l'iddoc del documento che innesca il giro. può essere sia il contratto ( CONTRATTO_GARA / SCRITTURA_PRIVATA ) sia l'id della convenzione ( CONVENZIONE )</param>
        /// <returns>Un oggetto HttpResponseMessage contenente la stringa UTF8 con media/type 'text/html' con l'esito della richiesta nella forma 1#esito positivo o 0#errore</returns>
        [HttpGet]
        public HttpResponseMessage GenerateXml(string id = "", int idpfu = -20, string lotto = "", string operation = "", int idContrattoConv = 0)
        {
            var esito = "";
            var strCause = "";
            var connectionString = ConfigurationManager.AppSettings["db.conn"];

            var guid = _utils.GetNewGuid();

            try
            {

                var bDeserta = false;

                if (id == "")
                    throw new ApplicationException("Parametro 'id' obbligatorio");

                var testId = int.TryParse(id, out var idDoc);

                if (!testId)
                {
                    throw new ApplicationException("Parametro 'id' non valido");
                }

                var currentPath = GetCurrentPath();

                strCause = "Recupero di template_can_29";
                var xmlbase = _utils.GetXmlTemplate("template_can_29", currentPath);

                strCause = "Recupero di template_can_29_contract";
                var xmlContratti = _utils.GetXmlTemplate("template_can_29_contract", currentPath);

                strCause = "Recupero di template_can_29_lot_result";
                var xmlLotResult = _utils.GetXmlTemplate("template_can_29_lot_result", currentPath);

                strCause = "Recupero di template_can_29_lots";
                var xmlLotti = _utils.GetXmlTemplate("template_can_29_lots", currentPath);

                strCause = "Recupero di template_can_29_organization";
                var xmlOrgs = _utils.GetXmlTemplate("template_can_29_organization", currentPath);

                strCause = "Recupero di template_deserta_can_29";
                var xmlBaseDeserta = _utils.GetXmlTemplate("template_deserta_can_29", currentPath);

                strCause = "Recupero di template_deserta_can_29_result";
                var xmlLotResultDeserta = _utils.GetXmlTemplate("template_deserta_can_29_result", currentPath);

                strCause = "Recupero di template_can_29_tendering_party";
                var xmlTenderingParty = _utils.GetXmlTemplate("template_can_29_tendering_party", currentPath);

                strCause = "Recupero di template_can_29_lot_tender";
                var xmlLotTender = _utils.GetXmlTemplate("template_can_29_lot_tender", currentPath);

                using (var connection = new SqlConnection(connectionString))
                {
                    strCause = "Apertura della connessione sql";
                    connection.Open();

                    string strSql;
                    var idProc = 0;
                    var idPda = 0;
                    var numeroLotto = ""; //caso base : non si filtra per numero lotto
                    SqlCommand cmd1;

                    if (string.IsNullOrEmpty(operation))
                    {
                        operation = "";
                    }


                    if (!operation.ToUpper().Equals("DESERTA"))
                    {
                        strCause = "Recupero l'id della procedura";

                        //Caso base. Vale per il caso "monolotto" e per "multilotto" ( tutti i lotti ). l'id input è la pda
                        strSql = "select LinkedDoc as idProc, id as idPda, '' as NumeroLotto from ctl_doc with(nolock) where id = @idDoc and tipodoc = 'PDA_MICROLOTTI'";

                        if (operation.ToLower() == "singolo_lotto")
                        {
                            //L'id chiamante non è la PDA ma l'id della document_microlotti_dettagli del singolo lotto
                            strSql = @"select  b.LinkedDoc as idProc, b.id as idPda, a.NumeroLotto as NumeroLotto
		                                from document_microlotti_dettagli a with(nolock) 
				                                inner join ctl_doc b with(nolock) on b.id = a.IdHeader
		                                where a.id = @idDoc";
                        }

                        cmd1 = new SqlCommand(strSql, connection);
                        cmd1.Parameters.AddWithValue("@idDoc", idDoc);

                        using (var rs = cmd1.ExecuteReader())
                        {
                            if (rs.Read())
                            {
                                idProc = (int)rs["idProc"];
                                idPda = (int)rs["idPda"];
                                numeroLotto = (string)rs["NumeroLotto"]; //Prendiamo il numero lotto dal "contesto chiamante"
                            }
                            else
                            {
                                throw new ApplicationException("PDA non trovata");
                            }
                        }

                        //Se il chiamante vuole un numero lotto specifico ( o una lista )
                        if (!string.IsNullOrEmpty(lotto))
                        {
                            numeroLotto = lotto;
                        }
                    }
                    else
                    {
                        idProc = idDoc;
                    }


                    strSql = @"select  isnull(RecivedIstanze,0) as RecivedIstanze,
		                                a.StatoFunzionale
	                                from ctl_doc a with(nolock)
			                                inner join document_bando b with(nolock) on b.idHeader = a.Id
	                                where a.id = @idProc";
                    cmd1 = new SqlCommand(strSql, connection);
                    cmd1.Parameters.AddWithValue("@idProc", idProc);

                    using (var rs = cmd1.ExecuteReader())
                    {
                        if (rs.Read())
                        {
                            var recivedIstanze = (int)rs["RecivedIstanze"];
                            var statoFunz = (string)rs["StatoFunzionale"];

                            if (recivedIstanze == 0 || statoFunz.ToLower().Equals("revocato"))
                                bDeserta = true;

                        }
                    }

                    if (bDeserta)
                        xmlbase = xmlBaseDeserta;

                    if (!operation.ToUpper().Equals("DESERTA"))
                    {
                        strCause = "Invocazione della stored per il popolamento della tabella di buffer";
                        strSql = "exec E_FORMS_CAN29_POPOLA_BUFFER @idPda, -20, @guid, @numeroLotto, @idDocContrConv";

                        cmd1 = new SqlCommand(strSql, connection);
                        cmd1.Parameters.AddWithValue("@idPda", idPda);
                        cmd1.Parameters.AddWithValue("@guid", guid);
                        cmd1.Parameters.AddWithValue("@numeroLotto", numeroLotto);
                        cmd1.Parameters.AddWithValue("@idDocContrConv", idContrattoConv);
                        cmd1.ExecuteNonQuery();
                    }

                    strCause = "Invocazione del metodo GetOrganizations";
                    var organizations = GetOrganizations(connection, idProc, idPda,guid, numeroLotto, xmlOrgs, bDeserta, idContrattoConv);
                    xmlbase = xmlbase.Replace("@@@NOTICE_RESULT_ORGANIZATIONS@@@", organizations);

                    //Se la gara è deserta non ha senso gestire i blocchi XML dei lotti result e dei lotti contract
                    if (!bDeserta)
                    {
                        strCause = "Invocazione del metodo GetTenderingParty";
                        var tenderingParty = GetTenderingParty(connection, idProc, idPda, guid, numeroLotto, xmlTenderingParty, idContrattoConv);
                        xmlbase = xmlbase.Replace("@@@NOTICE_RESULT_TENDERING_PARTY@@@", tenderingParty);

                        strCause = "Invocazione del metodo GetLotTender";
                        var tenderLot = GetLotTender(connection, idProc, idPda, guid, numeroLotto, xmlLotTender, idContrattoConv);
                        xmlbase = xmlbase.Replace("@@@NOTICE_RESULT_LOT_TENDER@@@", tenderLot);

                        strCause = "Invocazione del metodo GetLottiResult";
                        var lottiResult = GetLottiResult(connection, idPda, guid, xmlLotResult, numeroLotto, idContrattoConv: idContrattoConv);
                        xmlbase = xmlbase.Replace("@@@NOTICE_RESULT_LOT_RESULT@@@", lottiResult);

                        strCause = "Invocazione del metodo GetLottiContract";
                        var lottiContract = GetLottiContract(connection, idPda, guid, xmlContratti, idContrattoConv);
                        xmlbase = xmlbase.Replace("@@@NOTICE_RESULT_SETTLED_CONTRACT@@@", lottiContract);
                    }
                    else
                    {
                        strCause = "Invocazione del metodo GetLottiResult";
                        var lottiResult = GetLottiResult(connection, idProc, guid, xmlLotResultDeserta,"", true, idContrattoConv);
                        xmlbase = xmlbase.Replace("@@@NOTICE_RESULT_LOT_RESULT@@@", lottiResult);
                    }
                        
                    strCause = "Invocazione del metodo getLotti";
                    var lotti = GetLotti(connection, idProc, numeroLotto, xmlLotti);
                    xmlbase = xmlbase.Replace("@@@PROCUREMENT_PROJECT_LOT@@@", lotti);

                    strCause = "Esecuzione della stored E_FORMS_CN16_DATI_GARA";
                    strSql = "EXEC E_FORMS_CN16_DATI_GARA @idProc, -20, '', @guid, @idDocContrConv";

                    cmd1 = new SqlCommand(strSql, connection);
                    cmd1.Parameters.AddWithValue("@idProc", idProc);
                    cmd1.Parameters.AddWithValue("@guid", guid);
                    cmd1.Parameters.AddWithValue("@idDocContrConv", idContrattoConv);

                    using (var rs = cmd1.ExecuteReader())
                    {
                        if (rs.Read())
                        {
                            xmlbase = _utils.ElabXmlDb(rs, xmlbase);
                        }
                        else
                        {
                            throw new ApplicationException("Dati gara essenti");
                        }
                    }


                    //Dopo aver completato la produzione dell'xml lo vado a validare e solo se si supera con successo la validate si scrive l'xml nel DB, viceversa restituisco errore
                    var xmlVal = new XMLValidation();

                    //Errori Cablati
                    string XSDPath = "Il percorso fornito per il file XSD risulta incorretto. Controlla se il file esiste";
                    string XMLPath = "Il percorso fornito per il file XML risulta incorretto. Controlla se il file esiste";
                    string XSD = "Errore nel recupero dell'XSD";
                    string ValidateXML = "Errore di validazione file XML";
                    string ReadXML = "Errore di lettura file XML con schema XSD";

                    //Parametri Cablati
                    string Xml = string.Empty;
                    string Xsd = "UBL-ContractAwardNotice-2.3.xsd";
                    bool isXmlPath = false;
                    bool isXsdPath = true;

                    var xmlResult = xmlVal.ValidateXML(xmlbase, Xsd, isXmlPath, isXsdPath);

                    //Se ho avuto un errore qualsiasi entro nel merito del motivo
                    if (!xmlResult.Esit)
                    {
                        if (xmlResult.Error != Errors.RuntimeException)
                        {
                            var erroreXsd = $"TIPO ERRORE : {xmlResult.Error} -- ";

                            erroreXsd += string.Join(" -- ", xmlResult.ValidationErrors);

                            strCause = "Scrittura dell'errore XSD nella Document_E_FORM_PAYLOADS";
                            strSql = @"INSERT INTO Document_E_FORM_PAYLOADS( idHeader, operationDate, operationType, idpfu, payload )
										VALUES ( @idProc, getDate(), @opType, @idPfu, @payload )";

                            cmd1 = new SqlCommand(strSql, connection);
                            cmd1.Parameters.AddWithValue("@idProc", idProc);
                            cmd1.Parameters.AddWithValue("@opType", "ERRORE_CAN29");
                            cmd1.Parameters.AddWithValue("@idPfu", idpfu);
                            cmd1.Parameters.AddWithValue("@payload", erroreXsd);

                            cmd1.ExecuteNonQuery();

                            strCause = "Scrittura dell'xml non valido nella Document_E_FORM_PAYLOADS";

                            cmd1 = new SqlCommand(strSql, connection);
                            cmd1.Parameters.AddWithValue("@idProc", idProc);
                            cmd1.Parameters.AddWithValue("@opType", "XML_NON_VALIDO_CAN29");
                            cmd1.Parameters.AddWithValue("@idPfu", idpfu);
                            cmd1.Parameters.AddWithValue("@payload", xmlbase);

                            cmd1.ExecuteNonQuery();


                            var xmlErrConf = ConfigurationManager.AppSettings[$"XMLValidation.Error.{xmlResult.Error}"];

                            if (!string.IsNullOrEmpty(xmlErrConf))
                            {
                                throw new ConfigurationException(xmlErrConf);
                            }

                            //Fallback nel caso in cui non ci sono i parametri nel webconfig
                            switch (xmlResult.Error)
                            {
                                case Errors.XSDPath:
                                    throw new ConfigurationException(XSDPath);
                                case Errors.XMLPath:
                                    throw new ConfigurationException(XMLPath);
                                case Errors.XSD:
                                    throw new ConfigurationException(XSD);
                                case Errors.ValidateXML:
                                    throw new ConfigurationException(ValidateXML);
                                case Errors.ReadXML:
                                    throw new ConfigurationException(ReadXML);
                                default:
                                    throw new ConfigurationException("Errore validazione XML. Tipo non gestito"); //Non capiterà mai
                            }

                        }

                        throw new Exception(xmlResult.RuntimeException);

                    }

                    //Inserisco l'xml in tabella solo se è valido rispetto agli XSD

                    strCause = "Scrittura nella Document_E_FORM_PAYLOADS";
                    //Inserisco l'xml generato nel DB e lo collego alla procedura di gara
                    strSql = @"INSERT INTO Document_E_FORM_PAYLOADS( idHeader, operationDate, operationType, idpfu, payload )
									VALUES ( @idProc, getDate(), @opType, @idPfu, @payload )";

                    cmd1 = new SqlCommand(strSql, connection);
                    cmd1.Parameters.AddWithValue("@idProc", idProc);
                    cmd1.Parameters.AddWithValue("@opType", "CAN29");
                    cmd1.Parameters.AddWithValue("@idPfu", idpfu);
                    cmd1.Parameters.AddWithValue("@payload", xmlbase);

                    cmd1.ExecuteNonQuery();

                }

                if (string.IsNullOrEmpty(xmlbase))
                {
                    throw new ApplicationException("Errore nella generazione. XML vuoto");
                }

                esito = "1#OK";

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

                if (!operation.ToUpper().Equals("DESERTA"))
                {
                    //Ripuliamo i dati di lavoro
                    using (var connection = new SqlConnection(connectionString))
                    {
                        strCause = "Apertura della connessione sql";
                        connection.Open();
                        const string strSql = "delete from Document_E_FORM_BUFFER where guid = @Guid";

                        var cmd1 = new SqlCommand(strSql, connection);
                        cmd1.Parameters.AddWithValue("@Guid", guid);
                        cmd1.ExecuteNonQuery();
                    }
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

        private string GetLottiContract(SqlConnection connection, int idPda, string guid, string xmlLotContract, int idContrattoConv = 0)
        {
            var output = "";
            const string strSql = "exec E_FORMS_CAN29_LOTTI_CONTRACT @idPda, -20, @guid, '', @idDocContrConv";

            //-- non serve passare @numeroLotto alla E_FORMS_CAN29_LOTTI_CONTRACT perchè i dati li prendiamo dalla Document_E_FORM_BUFFER dove 
            //--    se era richiesto un filtro per numero lotto è stato già applicato ( insert nella tabella di buffer )

            var cmd1 = new SqlCommand(strSql, connection);
            cmd1.Parameters.AddWithValue("@idPda", idPda);
            cmd1.Parameters.AddWithValue("@guid", guid);
            cmd1.Parameters.AddWithValue("@idDocContrConv", idContrattoConv);

            using (var rs = cmd1.ExecuteReader())
            {
                while (rs.Read())
                {
                    output += _utils.ElabXmlDb(rs, xmlLotContract);
                }

            }

            return output;
        }

        private string GetLottiResult(SqlConnection connection, int idDoc, string guid, string xmlLotRes, string numeroLotto = "", bool bDeserta = false, int idContrattoConv = 0)
        {
            var output = "";

            SqlCommand cmd1;

            if (!bDeserta)
            {
                const string strSql = "exec E_FORMS_CAN29_LOTTI_RESULT @idPda, -20, @guid, @numeroLotto, @idDocContrConv";

                cmd1 = new SqlCommand(strSql, connection);
                cmd1.Parameters.AddWithValue("@idPda", idDoc);
                cmd1.Parameters.AddWithValue("@guid", guid);
                cmd1.Parameters.AddWithValue("@numeroLotto", numeroLotto);
                cmd1.Parameters.AddWithValue("@idDocContrConv", idContrattoConv);
            }
            else
            {
                const string strSql = "exec E_FORMS_CAN29_DESERTA_RESULT @idProc, -20";

                cmd1 = new SqlCommand(strSql, connection);
                cmd1.Parameters.AddWithValue("@idProc", idDoc);
            }

            using (var rs = cmd1.ExecuteReader())
            {
                while (rs.Read())
                {
                    output += _utils.ElabXmlDb(rs, xmlLotRes);
                }

            }

            return output;
        }

        private string GetOrganizations(SqlConnection connection, int idProc, int idPda, string guid, string numeroLotto, string xmlOrgs, bool bDeserta = false, int idContrattoConv = 0)
        {
            var output = "";
            var strSql = "exec E_FORMS_CN16_DATI_ENTE @idProc, -20, 'GET_ORG=YES'";

            var cmd1 = new SqlCommand(strSql, connection);
            cmd1.Parameters.AddWithValue("@idProc", idProc);

            using (var rs = cmd1.ExecuteReader())
            {
                while (rs.Read())
                {
                    output += _utils.ElabXmlDb(rs, xmlOrgs);
                }

            }

            if (!bDeserta)
            {
                strSql = "exec E_FORMS_CAN29_OE_PARTECIPANTI @idProc , @idPDA , -20 , @guid , @numeroLotto, @idDocContrConv";
                cmd1 = new SqlCommand(strSql, connection);
                cmd1.Parameters.AddWithValue("@idProc", idProc);
                cmd1.Parameters.AddWithValue("@idPDA", idPda);
                cmd1.Parameters.AddWithValue("@guid", guid);
                cmd1.Parameters.AddWithValue("@numeroLotto", numeroLotto);
                cmd1.Parameters.AddWithValue("@idDocContrConv", idContrattoConv);

                using (var rs = cmd1.ExecuteReader())
                {
                    while (rs.Read())
                    {
                        output += _utils.ElabXmlDb(rs, xmlOrgs);
                    }

                }
            }

            if (string.IsNullOrEmpty(output))
            {
                throw new ApplicationException("Organizzazioni assenti");
            }

            return output;
        }

        private string GetTenderingParty(SqlConnection connection, int idProc, int idPda, string guid, string numeroLotto, string xmlTendParty, int idContrattoConv = 0)
        {
            var output = "";

            var strSql = "exec E_FORMS_CAN29_TENDERING_PARTY @idProc , @idPDA , -20 , @guid , @numeroLotto, @idDocContrConv";
            var cmd1 = new SqlCommand(strSql, connection);
            cmd1.Parameters.AddWithValue("@idProc", idProc);
            cmd1.Parameters.AddWithValue("@idPDA", idPda);
            cmd1.Parameters.AddWithValue("@guid", guid);
            cmd1.Parameters.AddWithValue("@numeroLotto", numeroLotto);
            cmd1.Parameters.AddWithValue("@idDocContrConv", idContrattoConv);

            using (var rs = cmd1.ExecuteReader())
            {
                while (rs.Read())
                {
                    output += _utils.ElabXmlDb(rs, xmlTendParty);
                }
            }

            //if (string.IsNullOrEmpty(output))
            //{
            //    throw new ApplicationException("TenderingParty assenti");
            //}

            return output;
        }

        private string GetLotTender(SqlConnection connection, int idProc, int idPda, string guid, string numeroLotto, string xmlTenderLot, int idContrattoConv = 0)
        {
            var output = "";

            var strSql = "exec E_FORMS_CAN29_LOT_TENDER @idProc , @idPDA , -20 , @guid , @numeroLotto, @idDocContrConv";
            var cmd1 = new SqlCommand(strSql, connection);
            cmd1.Parameters.AddWithValue("@idProc", idProc);
            cmd1.Parameters.AddWithValue("@idPDA", idPda);
            cmd1.Parameters.AddWithValue("@guid", guid);
            cmd1.Parameters.AddWithValue("@numeroLotto", numeroLotto);
            cmd1.Parameters.AddWithValue("@idDocContrConv", idContrattoConv);

            using (var rs = cmd1.ExecuteReader())
            {
                while (rs.Read())
                {
                    output += _utils.ElabXmlDb(rs, xmlTenderLot);
                }
            }

            //if (string.IsNullOrEmpty(output))
            //{
            //    throw new ApplicationException("TenderLot assenti");
            //}

            return output;
        }

        private string GetLotti(SqlConnection connection, int idProc, string numeroLotto, string xmlLotti)
        {
            var output = ""; //l'elenco dei blocchi XML dei lotti
            const string strSql = "EXEC E_FORMS_CN16_DATI_LOTTI @idProc,-20,'',@numeroLotto";
            
            var cmd1 = new SqlCommand(strSql, connection);
            cmd1.Parameters.AddWithValue("@idProc", idProc);
            cmd1.Parameters.AddWithValue("@numeroLotto", numeroLotto);

            using (var rs = cmd1.ExecuteReader())
            {
                while (rs.Read())
                {
                    output += _utils.ElabXmlDb(rs, xmlLotti);
                }

            }

            if (string.IsNullOrEmpty(output))
            {
                throw new ApplicationException("Lotti assenti");
            }

            return output;
        }
    }
}
