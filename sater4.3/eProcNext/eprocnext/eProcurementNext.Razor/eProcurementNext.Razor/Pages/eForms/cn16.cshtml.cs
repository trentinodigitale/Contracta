using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.Core.Storage;
using eProcurementNext.Core.XMLValidation;
using eProcurementNext.Razor.Model;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.VisualStudio.TestPlatform.Utilities;
using System.Data.SqlClient;
using System.Runtime.Intrinsics.X86;
using System.Web;
using System.Xml;

namespace eProcurementNext.Razor.Pages.eForms
{
    public class Cn16Model : PageModel
    {
        private static readonly string BasePath = AppDomain.CurrentDomain.BaseDirectory;
        private readonly EformUtils _utils = new();

        public string? DownloadCn16(int idProc)
        {
            const string strSql = "select top 1 isnull(payload,'') as XML_CN16 from Document_E_FORM_PAYLOADS with(nolock) where idheader = @idProc and operationType = 'CN16' order by idRow desc";

            Dictionary<string, dynamic?>? param = new() { { "@idProc", idProc } };

            CommonDbFunctions db = new();
            var rs = db.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString, param);

            if (rs == null || rs.RecordCount == 0) throw new XmlException("0#Nessun XML generato");

            return (string)rs["XML_CN16"]!;

        }

        public string? DownloadChangeNotice(int idDoc)
        {
            var strSql = "select LinkedDoc from ctl_doc with(nolock) where id = @idDoc";

            Dictionary<string, dynamic?>? param = new() { { "@idDoc", idDoc } };

            CommonDbFunctions db = new();
            var rs = db.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString, param);

            if (rs == null || rs.RecordCount == 0) throw new XmlException("0#Fallito recupero della procedura");

            var idGara = (int)rs["LinkedDoc"]!;

            strSql = "select top 1 isnull(payload,'') as XML_CHANGE_NOTICE from Document_E_FORM_PAYLOADS with(nolock) where idheader = @idProc and operationType = 'CN16_CHANGE_NOTICE' order by idRow desc";

            param.Clear();
            param.Add("@idProc", idGara);
            rs = db.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString, param);

            if (rs == null || rs.RecordCount == 0) throw new XmlException("0#Nessun XML generato");

            return (string)rs["XML_CHANGE_NOTICE"]!;

        }

        public string GenerateXml(int idDoc, int idpfu = -20, string operation = "")
        {
            var esito = "";
            var strCause = "";

            try
            {
                
                strCause = "Recupero di template_cn16";
                var xmlbase = _utils.GetXmlTemplate("template_cn16", GetCurrentPath());

                strCause = "Recupero di template_cn16_lotti";
                var xmlLotti = _utils.GetXmlTemplate("template_cn16_lotti", GetCurrentPath());

                strCause = "Recupero di template_can_29_organization";
                var xmlOrgs = _utils.GetXmlTemplate("template_can_29_organization", GetCurrentPath());

                if (string.IsNullOrEmpty(operation))
                {
                    operation = "";
                }

                using (var connection = new SqlConnection(ApplicationCommon.Application.ConnectionString))
                {
                    strCause = "Apertura della connessione sql";
                    connection.Open();

                    string strSql;
                    var idProc = idDoc;

                    CommonDbFunctions db = new();
                    TSRecordSet? rs;

                    if (operation.ToUpper().Equals("CHANGE_NOTICE"))
                    {
                        strCause = "Recupero di template_cn16_changes";
                        var xmlChanges = _utils.GetXmlTemplate("template_cn16_changes", GetCurrentPath());

                        strCause = "Recupero di template_cn16_change_list";
                        var xmlChangeList = _utils.GetXmlTemplate("template_cn16_change_list", GetCurrentPath());

                        //L'id in input in caso di change notice è l'id del documento di rettifica/proroga/revoca e quindi dobbiamo recuperare dal linked doc la gara
                        strSql = "select linkeddoc as idProc from ctl_doc with(nolock) where id = @idDoc";

                        Dictionary<string, dynamic?>? parmS = new() { { "@idDoc", idDoc } };
                        rs = db.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString, parmS);
                        
                        if ( rs != null && rs!.RecordCount > 0 )
                        {
                            rs.MoveFirst();
                            idProc = (int)rs["idProc"]!;
                        }
                        else
                        {
                            throw new ApplicationException("Fallito recupero gara");
                        }
                        

                        strCause = "Esecuzione della stored E_FORMS_CHANGE_NOTICE";
                        strSql = "EXEC E_FORMS_CHANGE_NOTICE @idDoc, @idProc, @idpfu";

                        parmS.Clear();

                        parmS.Add("@idDoc", idDoc);
                        parmS.Add("@idProc", idProc);
                        parmS.Add("@idpfu", idpfu);

                        rs = db.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString, parmS);

                        if (rs != null && rs!.RecordCount > 0)
                        {
                            rs.MoveFirst();

                            //Itero sugli N criteri di esclusione andandoli ad accodare all'xml complessivo
                            while (!rs.EOF)
                            {
                                xmlChanges = _utils.ElabXmlDb(rs, xmlChanges);
                                rs.MoveNext();
                            }
                        }
                        else
                        {
                            throw new ApplicationException("Dati CHANGE NOTICE essenti");
                        }

                        strCause = "Recupero l'elenco dei change list";
                        var xmlListaChange = GetChangeList(connection, idDoc, idProc, xmlChangeList);

                        //Nel blocco changes sostituisco gli EVENTUALI change
                        strCause = "sostituisco gli eventuali change";
                        xmlChanges = xmlChanges.Replace("@@@CHANGE_LIST@@@", xmlListaChange);

                        //Nell'xml di cn16 aggiunto il blocco xml di changes
                        strCause = "sostituzione place holder CONTRACT_NOTICE_CHANGES";
                        xmlbase = xmlbase.Replace("@@@CONTRACT_NOTICE_CHANGES@@@", xmlChanges);
                    }


                    strCause = "Esecuzione della stored E_FORMS_CN16_DATI_ENTE";
                    strSql = "EXEC E_FORMS_CN16_DATI_ENTE @idProc";

                    Dictionary<string, dynamic?>? param = new() { { "@idProc", idProc } };
                    rs = db.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString, param);

                    string organizzazioni = "";

                    if (rs!.RecordCount > 0)
                    {
                        rs!.MoveFirst();

                        //Itero sugli N criteri di esclusione andandoli ad accodare all'xml complessivo
                        while (!rs.EOF)
                        {
                            organizzazioni += _utils.ElabXmlDb(rs, xmlOrgs);
                            rs.MoveNext();
                        }
                    }
                    else
                    {
                        throw new ApplicationException("Dati ente essenti");
                    }

                    xmlbase = xmlbase.Replace("@@@CONTRACT_NOTICE_ORGANIZATIONS@@@", organizzazioni);
                

                    strCause = "Esecuzione della stored E_FORMS_CN16_DATI_GARA";
                    strSql = "EXEC E_FORMS_CN16_DATI_GARA @idProc";

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
                

                    strCause = "Invocazione del metodo GetTenderReq";
                    var tenderReq = GetTenderReq(connection, idProc);
                    xmlbase = xmlbase.Replace("@@@SPECIFIC_TENDERER_REQUIREMENT@@@", tenderReq);

                    strCause = "Invocazione del metodo getLotti";
                    var newXmlLotti = GetLotti(connection, idProc, xmlLotti);
                    xmlbase = xmlbase.Replace("@@@LISTA_LOTTI@@@", newXmlLotti);

                    //Dopo aver completato la produzione dell'xml lo vado a validare e solo se si supera con successo la validate si scrive l'xml nel DB, viceversa restituisco errore
                    var basePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "wwwroot", "eForms", "XSD", "schemas", "maindoc");
                    var xmlVal = new XMLValidation(basePath,true);

                    //Errori Cablati
                    const string xsdPath = "Il percorso fornito per il file XSD risulta incorretto. Controlla se il file esiste";
                    const string xmlPath = "Il percorso fornito per il file XML risulta incorretto. Controlla se il file esiste";
                    const string xsd = "Errore nel recupero dell'XSD";
                    const string validateXml = "Errore di validazione file XML";
                    const string readXml = "Errore di lettura file XML con schema XSD";

                    //Parametri Cablati
                    var xml = string.Empty;
                    const string xsdName = "UBL-ContractNotice-2.3.xsd";
                    const bool isXmlPath = false;
                    const bool isXsdPath = true;

                    var xmlResult = xmlVal.ValidateXML(xmlbase, xsdName, isXmlPath, isXsdPath);

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

                            if (operation.ToUpper().Equals("CHANGE_NOTICE"))
                            {
                                param.Add("@opType", "ERRORE_CHANGE_NOTICE");
                            }
                            else
                            {
                                param.Add("@opType", "ERRORE_CN16");
                            }

                            param.Add("@idPfu", idpfu);
                            param.Add("@payload", erroreXsd);

                            db.Execute(strSql, ApplicationCommon.Application.ConnectionString, connection, parCollection:param);

                            strCause = "Scrittura dell'xml non valido nella Document_E_FORM_PAYLOADS";
                            param.Clear();

                            param.Add("@idProc", idProc);

                            if (operation.ToUpper().Equals("CHANGE_NOTICE"))
                            {
                                param.Add("@opType", "XML_NON_VALIDO_CHANGE_NOTICE");
                            }
                            else
                            {
                                param.Add("@opType", "XML_NON_VALIDO_CN16");
                            }

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

                    if (operation.ToUpper().Equals("CHANGE_NOTICE"))
                    {
                        param.Add("@opType", "CN16_CHANGE_NOTICE");
                    }
                    else
                    {
                        param.Add("@opType", "CN16");
                    }

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

            return esito;
        }

        private static string GetCurrentPath()
        {
            return BasePath;
        }

        private string GetLotti(SqlConnection connection, int idProc, string xmlBase)
        {
            var output = "";
            const string strSql = "EXEC E_FORMS_CN16_DATI_LOTTI @idProc";

            var templateCriterio = @"<efac:SelectionCriteria>
					                        <cbc:CriterionTypeCode listName=""selection-criterion"">@@@CODE_CRIT@@@</cbc:CriterionTypeCode>
					                     </efac:SelectionCriteria>";

            List<string> colToExclude = new List<string>
            {
                "LOTTO_CRITERI"
            };

            Dictionary<string, dynamic?>? param = new() { { "@idProc", idProc } };

            CommonDbFunctions db = new();
            var rs = db.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString, param);

            rs!.MoveFirst();

            while (!rs.EOF)
            {
                output += _utils.ElabXmlDb(rs, xmlBase, colToExclude);

                //Gestiamo manualmente il multi valore LOTTO_CRITERI
                var lottoCriteri = (string)rs["LOTTO_CRITERI"]!;
                var xmlListaCriteri = "";

                if (string.IsNullOrEmpty(lottoCriteri))
                {
                    throw new ApplicationException("Criteri di selezione assenti");
                }

                foreach (var criterio in lottoCriteri.Split(new string[] { "###" }, StringSplitOptions.None))
                {
                    if (string.IsNullOrEmpty(criterio)) continue;

                    var xmlCriterio = templateCriterio.Replace("@@@CODE_CRIT@@@", HttpUtility.HtmlEncode(criterio));
                    xmlListaCriteri += xmlCriterio;
                }

                output = output.Replace("@@@LOTTO_CRITERI@@@", xmlListaCriteri);

                rs.MoveNext();

            }


            if (string.IsNullOrEmpty(output))
            {
                throw new ApplicationException("Lotti assenti");
            }

            return output;
        }

        private string GetTenderReq(SqlConnection connection, int idProc)
        {
            var output = "";

            const string xmlBase = @"<cac:SpecificTendererRequirement>
						<cbc:TendererRequirementTypeCode listName=""exclusion-ground"">@@@EXLUSION_CODE@@@</cbc:TendererRequirementTypeCode>
						<cbc:Description languageID=""ITA"">@@@EXLUSION_DESCR@@@</cbc:Description>
					 </cac:SpecificTendererRequirement>";

            const string strSql = "EXEC E_FORMS_CN16_MOTIVO_ESCLUSIONE @idProc";

            Dictionary<string, dynamic?>? param = new() { { "@idProc", idProc } };

            CommonDbFunctions db = new();
            var rs = db.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString, param);

            rs!.MoveFirst();

            //Itero sugli N criteri di esclusione andandoli ad accodare all'xml complessivo
            while (!rs.EOF)
            {
                //Aggiungiamo gli N SpecificTendererRequirement
                output += _utils.ElabXmlDb(rs, xmlBase);
                rs.MoveNext();
            }


            if (string.IsNullOrEmpty(output))
            {
                throw new ApplicationException("Criteri di esclusione essenti");
            }

            return output;

        }

        private string GetChangeList(SqlConnection connection, int idDoc, int idProc, string xmlChangeList)
        {
            CommonDbFunctions db = new();

            const string strSql = "EXEC E_FORMS_CHANGE_LIST @idDoc, @idProc";

            Dictionary<string, dynamic?>? param = new()
            {
                { "@idDoc", idDoc },
                { "@idProc", idProc }
            };

            var rs = db.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString, param);

            string output = "";

            if (rs != null && rs!.RecordCount > 0)
            {
                rs!.MoveFirst();

                while (!rs.EOF)
                {
                    output += _utils.ElabXmlDb(rs, xmlChangeList);
                    rs.MoveNext();
                }
            }


            return output;
        }
    }
}
