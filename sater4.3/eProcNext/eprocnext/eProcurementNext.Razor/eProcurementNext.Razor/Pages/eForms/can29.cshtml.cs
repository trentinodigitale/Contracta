using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.Core.XMLValidation;
using eProcurementNext.Razor.Model;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data.SqlClient;
using System.Xml;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.Razor.Pages.eForms
{
    public class Can29Model : PageModel
    {
        private static readonly string BasePath = AppDomain.CurrentDomain.BaseDirectory;
        private readonly EformUtils _utils = new();

        /// <summary>
        /// Funzione di innesco per la generazione dell'eForm CAN-29 ( aggiudicazione ). Invocabile sia da codice che come api rest
        /// </summary>
        /// <param name="id">Parametro obbligatorio. è l'id della PDA se operation monolotto. è l'id della microlotti dettagli se operation singolo_lotto o ''. è l'id della gara se operation deserta</param>
        /// <param name="idpfu">Parametro opzionale. è l'idpfu dell'utente in sessione, -20 di default</param>
        /// <param name="lotto">parametro opzionale. vuoto per tutti i lotti oppure una lista separata da virgola con i numeri lotto richiesti ( o un solo numero lotto )</param>
        /// <param name="operation">parametro opzionale. operazione richiesta : stringa vuota, monolotto, singolo_lotto, deserta</param>
        /// <param name="idContrattoConv">parametro opzionale. è l'iddoc del documento che innesca il giro. può essere sia il contratto ( CONTRATTO_GARA / SCRITTURA_PRIVATA ) sia l'id della convenzione ( CONVENZIONE )</param>
        /// <returns>Un oggetto HttpResponseMessage contenente la stringa UTF8 con media/type 'text/html' con l'esito della richiesta nella forma 1#esito positivo o 0#errore</returns>
        public string GenerateXml(int idDoc, int idpfu = -20, string lotto = "", string operation = "", int idContrattoConv = 0)
        {
            var esito = "";
            var strCause = "";
            var guid = GetNewGuid();
            CommonDbFunctions db = new();
            Dictionary<string, dynamic?>? param = new();

            try
            {

                var bDeserta = false;
                
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

                using (var connection = new SqlConnection(ApplicationCommon.Application.ConnectionString))
                {
                    strCause = "Apertura della connessione sql";
                    connection.Open();

                    if (string.IsNullOrEmpty(operation))
                    {
                        operation = "";
                    }

                    var idProc = 0;
                    var idPda = 0;
                    var numeroLotto = ""; //caso base : non si filtra per numero lotto
                    var strSql = "";
                    TSRecordSet rs;

                    strCause = "Recupero l'id della procedura";

                    if (!operation.ToUpper().Equals("DESERTA"))
                    {
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



                        param = new Dictionary<string, dynamic?> { { "@idDoc", idDoc } };

                        rs = db.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString, param);

                        if (rs != null && rs.RecordCount > 0)
                        {
                            rs.MoveFirst();

                            idProc = (int)rs["idProc"]!;
                            idPda = (int)rs["idPda"]!;
                            numeroLotto = (string)rs["NumeroLotto"]!; //Prendiamo il numero lotto dal "contesto chiamante"

                        }
                        else
                        {
                            throw new ApplicationException("PDA non trovata");
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

                    param.Clear();
                    param.Add("@idProc", idProc);

                    rs = db.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString, param);

                    if (rs != null && rs.RecordCount > 0)
                    {
                        rs.MoveFirst();
                        var recivedIstanze = (int)rs["RecivedIstanze"]!;
                        var statoFunz = (string)rs["StatoFunzionale"]!;

                        if (recivedIstanze == 0 || statoFunz.ToLower().Equals("revocato"))
                            bDeserta = true;
                    }
                    
                    if (bDeserta)
                        xmlbase = xmlBaseDeserta;

                    if (!operation.ToUpper().Equals("DESERTA"))
                    {
                        strCause = "Invocazione della stored per il popolamento della tabella di buffer";
                        strSql = "exec E_FORMS_CAN29_POPOLA_BUFFER @idPda, -20, @guid, @numeroLotto";

                        param.Clear();
                        param.Add("@idPda", idPda);
                        param.Add("@guid", guid);
                        param.Add("@numeroLotto", numeroLotto);

                        db.Execute(strSql, ApplicationCommon.Application.ConnectionString, connection, parCollection: param);
                    }

                    strCause = "Invocazione del metodo GetOrganizations";
                    var organizations = GetOrganizations(connection, idProc, idPda, guid, numeroLotto, xmlOrgs, bDeserta);
                    xmlbase = xmlbase.Replace("@@@NOTICE_RESULT_ORGANIZATIONS@@@", organizations);

                    //Se la gara è deserta non ha senso gestire i blocchi XML dei lotti result e dei lotti contract
                    if (!bDeserta)
                    {
                        strCause = "Invocazione del metodo GetTenderingParty";
                        var tenderingParty = GetTenderingParty(connection, idProc, idPda, guid, numeroLotto, xmlTenderingParty);
                        xmlbase = xmlbase.Replace("@@@NOTICE_RESULT_TENDERING_PARTY@@@", tenderingParty);

                        strCause = "Invocazione del metodo GetLotTender";
                        var tenderLot = GetLotTender(connection, idProc, idPda, guid, numeroLotto, xmlLotTender);
                        xmlbase = xmlbase.Replace("@@@NOTICE_RESULT_LOT_TENDER@@@", tenderLot);

                        strCause = "Invocazione del metodo GetLottiResult";
                        var lottiResult = GetLottiResult(connection, idPda, guid, xmlLotResult, numeroLotto);
                        xmlbase = xmlbase.Replace("@@@NOTICE_RESULT_LOT_RESULT@@@", lottiResult);

                        strCause = "Invocazione del metodo GetLottiContract";
                        var lottiContract = GetLottiContract(connection, idPda, guid, xmlContratti);
                        xmlbase = xmlbase.Replace("@@@NOTICE_RESULT_SETTLED_CONTRACT@@@", lottiContract);
                    }
                    else
                    {
                        strCause = "Invocazione del metodo GetLottiResult";
                        var lottiResult = GetLottiResult(connection, idProc, guid, xmlLotResultDeserta, "", true);
                        xmlbase = xmlbase.Replace("@@@NOTICE_RESULT_LOT_RESULT@@@", lottiResult);
                    }

                    strCause = "Invocazione del metodo getLotti";
                    var lotti = GetLotti(connection, idProc, numeroLotto, xmlLotti);
                    xmlbase = xmlbase.Replace("@@@PROCUREMENT_PROJECT_LOT@@@", lotti);

                    strCause = "Esecuzione della stored E_FORMS_CN16_DATI_GARA";
                    strSql = "EXEC E_FORMS_CN16_DATI_GARA @idProc, -20, '', @guid";

                    param.Clear();
                    param.Add("@idProc", idProc);
                    param.Add("@guid", guid);

                    rs = db.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString, param);

                    if (rs != null && rs.RecordCount > 0)
                    {
                        rs.MoveFirst();
                        xmlbase = _utils.ElabXmlDb(rs, xmlbase);
                    }
                    else
                    {
                        throw new ApplicationException("Dati gara essenti");
                    }

                    
                    //Dopo aver completato la produzione dell'xml lo vado a validare e solo se si supera con successo la validate si scrive l'xml nel DB, viceversa restituisco errore
                    var basePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "wwwroot", "eForms", "XSD", "schemas", "maindoc");
                    var xmlVal = new XMLValidation(basePath, true);

                    //Errori Cablati
                    const string xsdPath = "Il percorso fornito per il file XSD risulta incorretto. Controlla se il file esiste";
                    const string xmlPath = "Il percorso fornito per il file XML risulta incorretto. Controlla se il file esiste";
                    const string xsd = "Errore nel recupero dell'XSD";
                    const string validateXml = "Errore di validazione file XML";
                    const string readXml = "Errore di lettura file XML con schema XSD";

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

                            param.Clear();
                            param.Add("@idProc", idProc);
                            param.Add("@opType", "ERRORE_CAN29");
                            param.Add("@idPfu", idpfu);
                            param.Add("@payload", erroreXsd);

                            db.Execute(strSql, ApplicationCommon.Application.ConnectionString,connection,parCollection:param);
                            
                            strCause = "Scrittura dell'xml non valido nella Document_E_FORM_PAYLOADS";

                            param.Clear();
                            param.Add("@idProc", idProc);
                            param.Add("@opType", "XML_NON_VALIDO_CAN29");
                            param.Add("@idPfu", idpfu);
                            param.Add("@payload", xmlbase);

                            db.Execute(strSql, ApplicationCommon.Application.ConnectionString, connection, parCollection: param);

                            var xmlErrConf = ConfigurationServices.GetKey($"XMLValidation.Error.{xmlResult.Error}", "");

                            if (!string.IsNullOrEmpty(xmlErrConf))
                            {
                                throw new EprocNextException(xmlErrConf);
                            }

                            //Fallback nel caso in cui non ci sono i parametri nel webconfig
                            switch (xmlResult.Error)
                            {
                                case Errors.XSDPath:
                                    throw new EprocNextException(xsdPath);
                                case Errors.XMLPath:
                                    throw new EprocNextException(xmlPath);
                                case Errors.XSD:
                                    throw new EprocNextException(xsd);
                                case Errors.ValidateXML:
                                    throw new EprocNextException(validateXml);
                                case Errors.ReadXML:
                                    throw new EprocNextException(readXml);
                                default:
                                    throw new EprocNextException("Errore validazione XML. Tipo non gestito"); //Non capiterà mai
                            }

                        }

                        throw new Exception(xmlResult.RuntimeException);

                    }

                    //Inserisco l'xml in tabella solo se è valido rispetto agli XSD

                    strCause = "Scrittura nella Document_E_FORM_PAYLOADS";
                    //Inserisco l'xml generato nel DB e lo collego alla procedura di gara
                    strSql = @"INSERT INTO Document_E_FORM_PAYLOADS( idHeader, operationDate, operationType, idpfu, payload )
									VALUES ( @idProc, getDate(), @opType, @idPfu, @payload )";

                    param.Clear();
                    param.Add("@idProc", idProc);
                    param.Add("@opType", "CAN29");
                    param.Add("@idPfu", idpfu);
                    param.Add("@payload", xmlbase);

                    db.Execute(strSql, ApplicationCommon.Application.ConnectionString, connection, parCollection: param);
                }

                if (string.IsNullOrEmpty(xmlbase))
                {
                    throw new ApplicationException("Errore nella generazione. XML vuoto");
                }

                esito = "1#OK";

            }
            catch (EprocNextException ex1)
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
                    const string strSql = "delete from Document_E_FORM_BUFFER where guid = @Guid";

                    param.Clear();
                    param.Add("@Guid", guid);
                    db.Execute(strSql, ApplicationCommon.Application.ConnectionString, parCollection: param);
                }
            }

            return esito;
        }

        private string GetLottiContract(SqlConnection connection, int idPda, string guid, string xmlLotContract)
        {
            var output = "";
            const string strSql = "exec E_FORMS_CAN29_LOTTI_CONTRACT @idPda, -20, @guid";

            //-- non serve passare @numeroLotto alla E_FORMS_CAN29_LOTTI_CONTRACT perchè i dati li prendiamo dalla Document_E_FORM_BUFFER dove 
            //--    se era richiesto un filtro per numero lotto è stato già applicato ( insert nella E_FORMS_CAN29_LOTTI_RESULT )

            Dictionary<string, dynamic?>? param = new();
            CommonDbFunctions db = new();

            param.Add("@idPDA", idPda);
            param.Add("@guid", guid);

            var rs = db.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString, param);

            if (rs!.RecordCount > 0)
            {
                rs!.MoveFirst();

                while (!rs.EOF)
                {
                    output += _utils.ElabXmlDb(rs, xmlLotContract);
                    rs.MoveNext();
                }
            }

            return output;
        }

        private string GetLottiResult(SqlConnection connection, int idDoc, string guid, string xmlLotRes, string numeroLotto = "", bool bDeserta = false)
        {
            var output = "";
            string strSql = "";
            CommonDbFunctions db = new();
            Dictionary<string, dynamic?>? param = new();

            if (!bDeserta)
            {
                strSql = "exec E_FORMS_CAN29_LOTTI_RESULT @idPda, -20, @guid, @numeroLotto";

                param.Add("@idPDA", idDoc);
                param.Add("@guid", guid);
                param.Add("@numeroLotto", numeroLotto);
            }
            else
            {
                strSql = "exec E_FORMS_CAN29_DESERTA_RESULT @idProc, -20";
                param.Add("@idProc", idDoc);
            }

            var rs = db.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString, param);

            if (rs!.RecordCount > 0)
            {
                rs!.MoveFirst();

                while (!rs.EOF)
                {
                    output += _utils.ElabXmlDb(rs, xmlLotRes);
                    rs.MoveNext();
                }
            }

            return output;
        }

        private string GetOrganizations(SqlConnection connection, int idProc, int idPda, string guid,string numeroLotto, string xmlOrgs, bool bDeserta = false)
        {
            var output = "";
            var strSql = "exec E_FORMS_CN16_DATI_ENTE @idProc, -20, 'GET_ORG=YES'";

            CommonDbFunctions db = new();
            Dictionary<string, dynamic?>? param = new() { { "@idProc", idProc } };
            var rs = db.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString, param);

            if (rs!.RecordCount > 0)
            {
                rs!.MoveFirst();

                while (!rs.EOF)
                {
                    output += _utils.ElabXmlDb(rs, xmlOrgs);
                    rs.MoveNext();
                }
            }

            if (!bDeserta)
            {
                strSql = "exec E_FORMS_CAN29_OE_PARTECIPANTI @idProc , @idPDA , -20 , @guid , @numeroLotto,1";

                param.Clear();
                param.Add("@idProc", idProc);
                param.Add("@idPDA", idPda);
                param.Add("@guid", guid);
                param.Add("@numeroLotto", numeroLotto);

                rs = db.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString, param);

                if (rs!.RecordCount > 0)
                {
                    rs!.MoveFirst();

                    while (!rs.EOF)
                    {
                        output += _utils.ElabXmlDb(rs, xmlOrgs);
                        rs.MoveNext();
                    }
                }
            }
            
            if (string.IsNullOrEmpty(output))
            {
                throw new ApplicationException("Organizzazioni assenti");
            }

            return output;
        }

        private string GetTenderingParty(SqlConnection connection, int idProc, int idPda, string guid, string numeroLotto, string xmlTendParty)
        {
            var output = "";


            var strSql = "exec E_FORMS_CAN29_TENDERING_PARTY @idProc , @idPDA , -20 , @guid , @numeroLotto";
            Dictionary<string, dynamic?>? param = new();
            CommonDbFunctions db = new();

            param.Add("@idProc", idProc);
            param.Add("@idPDA", idPda);
            param.Add("@guid", guid);
            param.Add("@numeroLotto", numeroLotto);

            var rs = db.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString, param);

            if (rs!.RecordCount > 0)
            {
                rs!.MoveFirst();

                while (!rs.EOF)
                {
                    output += _utils.ElabXmlDb(rs, xmlTendParty);
                    rs.MoveNext();
                }
            }

            return output;
        }

        private string GetLotTender(SqlConnection connection, int idProc, int idPda, string guid, string numeroLotto, string xmlTenderLot)
        {
            var output = "";

            var strSql = "exec E_FORMS_CAN29_LOT_TENDER @idProc , @idPDA , -20 , @guid , @numeroLotto";

            Dictionary<string, dynamic?>? param = new();
            CommonDbFunctions db = new();

            param.Add("@idProc", idProc);
            param.Add("@idPDA", idPda);
            param.Add("@guid", guid);
            param.Add("@numeroLotto", numeroLotto);

            var rs = db.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString, param);

            if (rs!.RecordCount > 0)
            {
                rs!.MoveFirst();

                while (!rs.EOF)
                {
                    output += _utils.ElabXmlDb(rs, xmlTenderLot);
                    rs.MoveNext();
                }
            }

            return output;
        }

        //private string GetLotti(SqlConnection connection, int idProc, string xmlLotti)
        private string GetLotti(SqlConnection connection, int idProc, string numeroLotto, string xmlLotti)
        {
            var output = ""; //l'elenco dei blocchi XML dei lotti
            const string strSql = "EXEC E_FORMS_CN16_DATI_LOTTI @idProc,-20,'',@numeroLotto";

            Dictionary<string, dynamic?>? param = new();
            CommonDbFunctions db = new();

            param.Add("@idProc", idProc);
            param.Add("@numeroLotto", numeroLotto);

            var rs = db.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString, param);

            if (rs!.RecordCount > 0)
            {
                rs!.MoveFirst();

                while (!rs.EOF)
                {
                    output += _utils.ElabXmlDb(rs, xmlLotti);
                    rs.MoveNext();
                }
            }

            if (string.IsNullOrEmpty(output))
            {
                throw new ApplicationException("Lotti assenti");
            }

            return output;
        }

        public string? DownloadCan29(int idProc)
        {
            const string strSql = "select top 1 isnull(payload,'') as XML_CAN29 from Document_E_FORM_PAYLOADS with(nolock) where idheader = @idProc and operationType = 'CAN29' order by idRow desc";

            Dictionary<string, dynamic?>? param = new() { { "@idProc", idProc } };

            CommonDbFunctions db = new();
            var rs = db.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString, param);

            if (rs == null || rs.RecordCount == 0) throw new XmlException("0#Nessun XML generato");

            return (string)rs["XML_CAN29"]!;
        }

        private static string GetCurrentPath()
        {
            return BasePath;
        }

    }
}
